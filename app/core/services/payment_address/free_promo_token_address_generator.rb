class Services::PaymentAddress::FreePromoTokenAddressGenerator
  def initialize(count_to_add = nil)
    @count_to_add   = count_to_add
    @currency       = 'ETH'
    @payment_system = PaymentSystemType::ANY_PAY_COINS
    @address_type   = PaymentAddressType::PROMO_TOKENS
    @currency_pool  = ENV['PROMO_TOKENS_ADDRESS_POOL'].to_i
  end

  def call
    count_generated = { currency: @currency, value: 0 }

    return count_generated unless Promocode.promo_token_enabled?
    tokens_to_add = @currency_pool - free_tokens_count
    return count_generated if tokens_to_add <= 0

    tokens_to_add = [tokens_to_add, @count_to_add].min if @count_to_add.present?
    count_generated[:value] = Services::PaymentSystem::MainWrapper.new.add_tokens(@currency, tokens_to_add, @payment_system, @address_type)
    count_generated
  end

  private

  def free_tokens_count
    ::PaymentAddress.by_currency(@currency).by_payment_system(@payment_system).by_address_type(@address_type).not_user.count
  end

end
