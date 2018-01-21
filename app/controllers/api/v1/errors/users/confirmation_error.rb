class API::V1::Errors::Users::ConfirmationError < API::V1::Errors::BaseException
  def initialize(message = I18n.t('devise.failure.unconfirmed'))
    super(message: message, status: 401, code: API::V1::Errors::Types::USER_CONFIRMATION_ERROR)
  end
end
