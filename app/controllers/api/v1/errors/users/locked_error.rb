class API::V1::Errors::Users::LockedError < API::V1::Errors::BaseException
  def initialize(message = I18n.t('devise.failure.locked'))
    super(message: message, status: 403, code: API::V1::Errors::Types::USER_LOCKED_ERROR)
  end
end
