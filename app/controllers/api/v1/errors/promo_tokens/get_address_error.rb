class API::V1::Errors::PromoTokens::GetAddressError < API::V1::Errors::BaseException
  def initialize(message = I18n.t('payment_address.promo_tokens.can_not_get_address'))
    super(message: message, status: 422, code: API::V1::Errors::Types::PROMO_TOKENS_GET_ADDRESS_ERROR)
  end
end
