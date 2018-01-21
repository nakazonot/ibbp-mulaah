class API::V1::Errors::IcosId::VerifyInProgressError < API::V1::Errors::BaseException
  def initialize(message = I18n.t('errors.messages.icos_id_verify_in_progress'))
    super(message: message, status: 409, code: API::V1::Errors::Types::ICOS_ID_VERIFY_IN_PROGRESS_ERROR)
  end
end

