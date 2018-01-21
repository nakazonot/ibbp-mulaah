class API::V1::Errors::Users::InvalidActivationCodeError < API::V1::Errors::BaseException
  def initialize(message = I18n.t('activation.errors.invalid_code'))
    super(message: message, status: 403, code: API::V1::Errors::Types::USER_INVALID_ACTIVATION_CODE)
  end
end
