class API::V1::Errors::IcosId::CreateAccountError < API::V1::Errors::BaseException
  def initialize(message = I18n.t('errors.messages.icos_id_can_not_create_account'))
    super(message: message, status: 409, code: API::V1::Errors::Types::ICOS_ID_CREATE_ACCOUNT_ERROR)
  end
end
