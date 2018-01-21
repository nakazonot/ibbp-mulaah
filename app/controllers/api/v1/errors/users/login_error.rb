class API::V1::Errors::Users::LoginError < API::V1::Errors::BaseException
  def initialize(message = I18n.t('devise.failure.invalid', authentication_keys: 'email'))
    super(message: message, status: 401, code: API::V1::Errors::Types::USER_LOGIN_ERROR)
  end
end
