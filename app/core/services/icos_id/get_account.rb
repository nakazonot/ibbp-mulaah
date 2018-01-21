class Services::IcosId::GetAccount
  include Concerns::Log::Logger

  ERROR_ICOS_ID_USER_NOT_EXIST      = 'error_icos_id_user_not_exist'.freeze
  ERROR_ICOS_ID_AUTHORIZATION_ERROR = 'error_icos_id_authorization_error'.freeze
  ERROR_ICOS_ID_SERVER_ERROR        = 'error_icos_id_server_error'.freeze
  ERROR_ICOS_ID_UNKNOWN             = 'error_icos_id_unknown'.freeze

  attr_reader :error, :data

  def initialize(email)
    @email = email
  end

  def call
    get_account

  rescue Services::IcosId::GetAccountError => e
    @error = e.message
    log_error("ICOS ID. Get account information: #{@email}. #{e.message}")
    nil
  end

  private

  def get_account
    handle_response(ApiWrappers::IcosId.new.get_account_by_email(@email))
  end

  def handle_response(response)
    if response == nil
      raise Services::IcosId::GetAccountError, ERROR_ICOS_ID_SERVER_ERROR
    elsif response['Status'] == 'ok'
      return @data = convert_user_information(response['Result'])
    elsif response['Status'] == 'error' && response['Result']&.first.present?
      if response['Result'].first['Message'] == 'Please sign in for this method'
        raise Services::IcosId::GetAccountError, ERROR_ICOS_ID_AUTHORIZATION_ERROR
      elsif response['Result'].first['Message'] == 'Client not found'
        raise Services::IcosId::GetAccountError, ERROR_ICOS_ID_USER_NOT_EXIST
      end
    end

    raise Services::IcosId::GetAccountError, ERROR_ICOS_ID_UNKNOWN
  end

  def convert_user_information(user_information_raw)
    {
      uid:                   user_information_raw['Id'],
      email:                 user_information_raw['Email'],
      first_name:            user_information_raw['FirstName'],
      middle_name:           user_information_raw['MiddleName'],
      last_name:             user_information_raw['LastName'],
      phone:                 user_information_raw['Phone'],
      lang:                  user_information_raw['Lang'],
      document_number:       user_information_raw['DocumentNumber'],
      use_g2fa:              user_information_raw['UseG2fa'],
      globalid_verify:       user_information_raw['GlobalidVerify'],
      globalid_agent_verify: user_information_raw['GlobalidAgentVerify'],
      netki_status:          user_information_raw['NetkiStatus'],
      kyc_status:            user_information_raw['KycStatus'],
      kyc_reason:            user_information_raw['KycReason'],
      kyc_at:                user_information_raw['KycAt']
    }
  end
end
