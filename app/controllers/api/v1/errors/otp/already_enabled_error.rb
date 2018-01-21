class API::V1::Errors::OTP::AlreadyEnabledError < API::V1::Errors::BaseException
  def initialize(message = I18n.t('errors.messages.otp_already_enabled'))
    super(message: message, status: 403, code: API::V1::Errors::Types::OTP_ALREADY_ENABLED_ERROR)
  end
end
