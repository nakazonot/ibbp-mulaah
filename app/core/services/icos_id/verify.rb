class Services::IcosId::Verify
  include Concerns::Log::Logger

  ERROR_USER_NOT_EXIST             = 'error_user_not_exist'.freeze
  ERROR_GET_ICOS_ID_ACCOUNT        = 'error_get_icos_id_account'.freeze
  ERROR_CREATE_ICOS_ID_ACCOUNT     = 'error_create_icos_id_account'.freeze
  ERROR_SEND_VERIFY                = 'error_send_verify'.freeze
  ERROR_ICOS_ID_ALREADY_VERIFIED   = 'error_icos_id_already_verified'.freeze
  ERROR_ICOS_ID_VERIFY_IN_PROGRESS = 'error_icos_id_verify_in_progress'.freeze

  attr_reader :error

  def initialize(user_id, params = {})
    @params  = params.to_h.symbolize_keys
    @user_id = user_id
  end

  def call
    find_user
    get_icos_id_information
    update_kyc_verification
    verify

  rescue Services::IcosId::VerifyError => e
    @error = e.message
    log_error("ICOS ID Verify: user ##{@user_id}, params: #{@params}, error: #{e.message}")
    nil
  end

  private

  def find_user
    @user = User.find_by(id: @user_id)
    raise Services::IcosId::VerifyError, ERROR_USER_NOT_EXIST if @user.nil?
  end

  def get_icos_id_information
    icos_id_get_account = Services::IcosId::GetAccount.new(@user.email)
    icos_id_get_account.call

    if icos_id_get_account.error.blank?
      process_kyc_data(icos_id_get_account.data)
    else
      if icos_id_get_account.error != Services::IcosId::GetAccount::ERROR_ICOS_ID_USER_NOT_EXIST
        raise Services::IcosId::VerifyError, ERROR_GET_ICOS_ID_ACCOUNT
      end

      icos_id_create_account = Services::IcosId::CreateAccount.new(@user.id)
      icos_id_create_account.call

      raise Services::IcosId::VerifyError, ERROR_CREATE_ICOS_ID_ACCOUNT if icos_id_create_account.error.present?

      process_kyc_data
    end
  end

  def update_kyc_verification
    kyc_verification = KycVerification.find_by(user_id: @user_id)
    kyc_verification.update({
      first_name:            @params[:first_name],
      middle_name:           @params[:middle_name],
      last_name:             @params[:last_name],
      phone:                 @params[:phone],
      gender:                @params[:gender],
      citizenship:           @params[:citizenship],
      document_number:       @params[:document_number],
      dob:                   @params[:dob],
      address: {
        address_line_1: @params[:address_line_1],
        address_line_2: @params[:address_line_2],
        address_line_3: @params[:address_line_3],
      },
      state:                @params[:state],
      city:                 @params[:city],
      country_code:         @params[:country_code],
    })
  end

  def prepare_documents
    documents = {
      front:  @params[:document_front],
      back:   @params[:document_back],
      proof:  @params[:document_proof],
      selfie: @params[:document_selfie],
    }

    @documents = {}
    documents.each do |key, document|
      if document.present?
        @documents[key] = File.new(document.tempfile)
      end
    end
  end

  def verify
    prepare_documents
    service_send_kyc = Services::IcosId::SendKyc.new(@user_id, @documents)
    service_send_kyc.call

    raise Services::IcosId::VerifyError, ERROR_SEND_VERIFY if service_send_kyc.error.present?
  end

  def process_kyc_data(response_data = {})
    kyc_verification = @user.kyc_verification
    status           = kyc_status_converter(response_data[:kyc_status])

    if kyc_verification.nil?
      kyc_verification = KycVerification.new(user_id: @user_id)
      kyc_verification.save
    end

    kyc_verification.update_column(:status, status)
    if response_data[:kyc_reason] != kyc_verification.deny_reason
      kyc_verification.update_column(:deny_reason, response_data[:kyc_reason])
    end

    if kyc_verification.approved?
      kyc_verification.update_column(:verified_at, response_data[:kyc_at])
      raise Services::IcosId::VerifyError, ERROR_ICOS_ID_ALREADY_VERIFIED if kyc_verification.approved?
    end

    raise Services::IcosId::VerifyError, ERROR_ICOS_ID_VERIFY_IN_PROGRESS if  kyc_verification.in_progress?
  end

  def kyc_status_converter(kyc_status)
    case kyc_status
    when 'approved'
      KycStatusType::APPROVED
    when 'disapproved'
      KycStatusType::REJECTED
    when 'sent'
      KycStatusType::IN_PROGRESS
    when 'in_work'
      KycStatusType::IN_PROGRESS
    else
      KycStatusType::DRAFT
    end
  end
end
