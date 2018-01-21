class Services::PaymentSystem::MainWrapper

  def enabled_payment_systems
    payment_systems = {
      PaymentSystemType::ANY_PAY_COINS => ApiWrappers::AnyPayCoins.new,
      PaymentSystemType::COIN_PAYMENTS => ApiWrappers::CoinPayments.new,
    }
    payment_systems.select { |k, system| system.enabled }
  end

  def enabled_payment_systems_for_deposit
    enabled_payment_systems.select { |k, system| system.enabled_for_deposit? }
  end


  def get_rates
    result = {}
    enabled_payment_systems_for_deposit.each do |k, system|
      result.merge!(system.get_rates) { |key, v1, v2| v1 }
    end
    result
  end

  def get_available_currencies
    result = {}
    enabled_payment_systems_for_deposit.each do |k, system|
      result.merge!(system.get_available_currencies) { |key, v1, v2| v1 }
    end
    result
  end


  def get_wrapper_by_payment_system(payment_system, address_type = PaymentAddressType::DEPOSIT)
    if address_type == PaymentAddressType::PROMO_TOKENS
      wrapper = enabled_payment_systems[payment_system]
    else
      wrapper = enabled_payment_systems_for_deposit[payment_system]
    end
    raise "Payment System in not enabled! params: #{{payment_system: payment_system}.to_json}" if wrapper.blank?
    wrapper
  end

  def add_tokens(currency, tokens_to_add, payment_system, address_type = PaymentAddressType::DEPOSIT,
                 print_result = false)
    wrapper = get_wrapper_by_payment_system(payment_system, address_type)

    added = 0
    step = wrapper.get_addresses_max_limit
    loop do
      break if tokens_to_add <= 0
      sleep(1)
      limit = (tokens_to_add - step) >= step ? step : tokens_to_add
      free_addresses = wrapper.add_tokens(currency, limit)
      next if free_addresses.nil?
      free_addresses.each do |address|
        added += 1
        address = create_free_address(currency, payment_system, address, address_type)
        print_address(address) if print_result
      end
      tokens_to_add -= limit
    end
    added
  end

  def free_address_pool(payment_system)
    wrapper = get_wrapper_by_payment_system(payment_system)
    wrapper.free_address_pool
  end

  private

  def create_free_address(currency, payment_system, options, address_type)
    new_address                 = ::PaymentAddress.new

    new_address.payment_address = options[:address]
    new_address.currency        = currency
    new_address.payment_system  = payment_system
    new_address.address_type    = address_type if address_type.present?
    new_address.user_id         = nil
    new_address.pubkey          = options[:pubkey] if options.has_key?(:pubkey)
    new_address.dest_tag        = options[:dest_tag] if options.has_key?(:dest_tag)
    new_address.ipn_url         = options[:ipn_url] if options.has_key?(:ipn_url)

    new_address.save!(validate: false)
    new_address
  end

  def print_address(address)
    log_string  = "#{address.payment_address}, coin_system: #{address.payment_system}, currency: #{address.currency}"
    log_string += ", pubkey: " + address.pubkey if address.pubkey.present?
    log_string += ", dest_tag: " + address.dest_tag if address.dest_tag.present?

    puts log_string
  end
end