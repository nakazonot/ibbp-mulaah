class API::V1::Errors::Users::PromocodeNotAddedError < API::V1::Errors::BaseException
  def initialize(message = I18n.t('promocode.not_added'))
    super(message: message, status: 422, code: API::V1::Errors::Types::USER_PROMOCODE_NOT_ADDED)
  end
end