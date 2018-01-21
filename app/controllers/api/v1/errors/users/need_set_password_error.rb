class API::V1::Errors::Users::NeedSetPasswordError < API::V1::Errors::BaseException
  def initialize(message = I18n.t('errors.messages.password_set_request'))
    super(message: message, status: 403, code: API::V1::Errors::Types::USER_NEED_SET_PASSWORD_ERROR)
  end
end
