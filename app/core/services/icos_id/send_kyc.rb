class Services::IcosId::SendKyc
  include Concerns::Log::Logger

  ERROR_USER_NOT_EXIST              = 'error_user_not_exist'.freeze
  ERROR_SEND_KYC_NOT_ALLOWED        = 'error_send_kyc_not_allowed'.freeze
  ERROR_KYC_NOT_EXIST               = 'error_kyc_not_exist'.freeze
  ERROR_ICOS_ID_AUTHORIZATION_ERROR = 'error_icos_id_authorization_error'.freeze
  ERROR_ICOS_ID_ALREADY_VERIFIED    = 'error_icos_id_already_verified'.freeze
  ERROR_ICOS_ID_UNKNOWN             = 'error_icos_id_unknown'.freeze
  ERROR_ICOS_ID_SERVER_ERROR        = 'error_icos_id_server_error'.freeze

  attr_reader :error

  def initialize(user_id, documents)
    @documents  = documents
    @user_id    = user_id
  end

  def call
    find_user
    build_kyc_data
    send_verification_request

  rescue Services::IcosId::SendKycError => e
    @error = e.message
    log_error("user: ##{@user_id}, error: #{e.message}")
    nil
  end

  private

  def find_user
    @user = User.find_by(id: @user_id)
    raise Services::IcosId::SendKycError, ERROR_USER_NOT_EXIST if @user.nil?
  end

  def build_kyc_data
    kyc = @user.kyc_verification
    raise Services::IcosId::SendKycError, ERROR_KYC_NOT_EXIST if kyc.nil?

    if [KycStatusType::APPROVED, KycStatusType::IN_PROGRESS].include?(kyc&.status)
      raise Services::IcosId::SendKycError, ERROR_SEND_KYC_NOT_ALLOWED
    end

    @kyc_data = kyc.kyc
    @kyc_data.merge!({
      email:     @user.email,
      address:   join_address_lines(@kyc_data[:address]),
      documents: @documents
    })
  end

  def send_verification_request
    handle_response(ApiWrappers::IcosId.new.kyc_verify(@kyc_data))
  end

  def join_address_lines(address_raw)
    addresses = []

    address_raw.each { |_key, address| addresses << address.strip if address&.strip.present? }

    addresses.join(' ')
  end

  def handle_response(response)
    if response == nil
      raise Services::IcosId::SendKycError, ERROR_ICOS_ID_SERVER_ERROR
    elsif response['Status'] == 'ok'
      return @user.kyc_verification.update(status: KycStatusType::IN_PROGRESS, sent_at: Time.current)
    elsif response['Status'] == 'error' && response['Result'].present?
      if response['Result'].first['Message'] == 'Please sign in for this method'
        raise Services::IcosId::SendKycError, ERROR_ICOS_ID_AUTHORIZATION_ERROR
      elsif response['Result'].first['Message'] == 'You can\'t to verify twice'
        raise Services::IcosId::SendKycError, ERROR_ICOS_ID_ALREADY_VERIFIED
      end
    end

    raise Services::IcosId::SendKycError, ERROR_ICOS_ID_UNKNOWN
  end
end
