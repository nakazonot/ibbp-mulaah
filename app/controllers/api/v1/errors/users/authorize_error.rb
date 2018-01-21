class API::V1::Errors::Users::AuthorizeError < API::V1::Errors::BaseException
  def initialize(message = I18n.t('devise.failure.unauthenticated'))
    super(message: message, status: 401, code: API::V1::Errors::Types::AUTHORIZE_ERROR)
  end
end
