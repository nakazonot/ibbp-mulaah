class API::V1::Errors::IcosId::AlreadyVerifiedError < API::V1::Errors::BaseException
  def initialize(message = I18n.t('errors.messages.icos_id_already_verified'))
    super(message: message, status: 409, code: API::V1::Errors::Types::ICOS_ID_ALREADY_VERIFIED_ERROR)
  end
end

