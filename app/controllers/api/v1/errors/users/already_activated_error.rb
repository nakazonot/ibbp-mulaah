class API::V1::Errors::Users::AlreadyActivatedError < API::V1::Errors::BaseException
  def initialize(message = I18n.t('activation.notice.already_activated'))
    super(message: message, status: 403, code: API::V1::Errors::Types::USER_ALREADY_ACTIVATED_ERROR)
  end
end
