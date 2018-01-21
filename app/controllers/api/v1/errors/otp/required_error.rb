class API::V1::Errors::OTP::RequiredError < API::V1::Errors::BaseException
  def initialize(message = I18n.t('otp.notice.required'))
    super(message: message, status: 401, code: API::V1::Errors::Types::OTP_REQUIRED_ERROR)
  end
end
