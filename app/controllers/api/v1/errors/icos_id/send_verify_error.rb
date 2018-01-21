class API::V1::Errors::IcosId::SendVerifyError < API::V1::Errors::BaseException
  def initialize(message = I18n.t('errors.messages.icos_id_can_not_send_verify'))
    super(message: message, status: 409, code: API::V1::Errors::Types::ICOS_ID_SEND_VERIFY_ERROR)
  end
end
