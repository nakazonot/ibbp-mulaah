class API::V1::Errors::OTP::NotEnabledError < API::V1::Errors::BaseException
  def initialize(message = I18n.t('errors.messages.otp_not_enabled'))
    super(message: message, status: 403, code: API::V1::Errors::Types::OTP_NOT_ENABLED_ERROR)
  end
end
