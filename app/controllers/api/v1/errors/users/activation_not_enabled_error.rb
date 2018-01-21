class API::V1::Errors::Users::ActivationNotEnabledError < API::V1::Errors::BaseException
  def initialize(message = I18n.t('activation.errors.not_required'))
    super(message: message, status: 403, code: API::V1::Errors::Types::USER_ACTIVATION_NOT_ENABLED)
  end
end
