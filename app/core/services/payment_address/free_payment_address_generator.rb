class Services::PaymentAddress::FreePaymentAddressGenerator
  def initialize(currency = nil, count_to_add = nil, print_result = false)
    @available_currencies = Parameter.available_currencies
    @currencies     = currency.blank? ? @available_currencies.keys : [currency]
    @count_to_add   = count_to_add
    @address_type   = PaymentAddressType::DEPOSIT
    @print_result   = print_result
  end

  def call
    count_generated = {}
    @currencies.each do |raw_currency|
      next if raw_currency == ExchangeRate::DEFAULT_CURRENCY
      payment_system = @available_currencies[raw_currency]['payment_system']
      @wrapper = Services::PaymentSystem::MainWrapper.new
      currency_pool = @wrapper.free_address_pool(payment_system)
      tokens_to_add = currency_pool - free_tokens_count(raw_currency, payment_system)
      next if tokens_to_add <= 0
      tokens_to_add = [tokens_to_add, @count_to_add].min if @count_to_add.present?

      count_generated[raw_currency] = @wrapper.add_tokens(raw_currency, tokens_to_add, payment_system,
                                                          @address_type, @print_result)
    end
    count_generated
  end

  private

  def free_tokens_count(currency, payment_system)
    ::PaymentAddress.by_currency(currency).by_payment_system(payment_system).by_address_type(@address_type).not_user.count
  end

end
