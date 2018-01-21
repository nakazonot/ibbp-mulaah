class API::V1::Errors::Users::UnauthenticatedError < API::V1::Errors::BaseException
  def initialize(message = I18n.t('devise.failure.unauthenticated'))
    super(message: message, status: 401, code: API::V1::Errors::Types::USER_UNAUTHENTICATED_ERROR)
  end
end