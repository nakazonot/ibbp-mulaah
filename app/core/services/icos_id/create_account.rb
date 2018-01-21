class Services::IcosId::CreateAccount
  include Concerns::Log::Logger

  ERROR_USER_NOT_EXIST              = 'error_user_not_exist'.freeze
  ERROR_ICOS_ID_EMAIL_ALREADY_TAKEN = 'error_icos_id_email_already_taken'.freeze
  ERROR_ICOS_ID_AUTHORIZATION_ERROR = 'error_icos_id_authorization_error'.freeze
  ERROR_ICOS_ID_SERVER_ERROR        = 'error_icos_id_server_error'.freeze
  ERROR_ICOS_ID_UNKNOWN             = 'error_icos_id_unknown'.freeze

  attr_reader :error

  def initialize(user_id)
    @user_id = user_id
  end

  def call
    find_user
    create_account

  rescue Services::IcosId::CreateAccountError => e
    @error = e.message
    log_error("user: ##{@user_id}. #{e.message}")
    nil
  end

  private

  def find_user
    @user = User.find_by(id: @user_id)
    raise Services::IcosId::CreateAccountError, ERROR_USER_NOT_EXIST if @user.nil?
  end

  def create_account
    params = {
      email:       @user.email,
      first_name:  @user.first_name,
      middle_name: @user.middle_name,
      last_name:   @user.last_name
    }

    handle_response(ApiWrappers::IcosId.new.create_account_by_email(params))
  end

  def handle_response(response)
    if response == nil
      raise Services::IcosId::CreateAccountError, ERROR_ICOS_ID_SERVER_ERROR
    elsif response['Status'] == 'ok'
      return KycMailer.message_created_icos_id_account_notification(@user.email).deliver_later
    elsif response['Status'] == 'error' && response['Result']&.first.present?
      if response['Result'].first['Message'] == 'Please sign in for this method'
        raise Services::IcosId::CreateAccountError, ERROR_ICOS_ID_AUTHORIZATION_ERROR
      elsif response['Result'].first['Message'] == 'This email address has already been taken.'
        raise Services::IcosId::CreateAccountError, ERROR_ICOS_ID_EMAIL_ALREADY_TAKEN
      end
    end

    raise Services::IcosId::CreateAccountError, ERROR_ICOS_ID_UNKNOWN
  end
end
