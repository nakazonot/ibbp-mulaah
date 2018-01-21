class Services::Coin::CoinCreator
  include Concerns::Log::Logger
  include Concerns::Currency

  def initialize(contract, opts = {})
    @contract             = contract
    @contract_info        = contract.info
    @user                 = contract.user
    @config_parameters    = Parameter.get_all
    @buy_from_all_balance = @contract_info['balances'].present?
    @from_admin           = opts[:created_by_user_id].present?
    @created_by_user_id   = opts[:created_by_user_id]
    @payment_description  = opts[:payment_description]
    @request              = opts[:request]
    @disable_bonus        = opts[:disable_bonus]
  end

  def call
    if @contract.payment.present?
      log_error("Contract already accepted. user: ##{@user.id}, contract: ##{@contract.id}.")
      return { error: true, msg: 'Contract already accepted.' } if @contract.payment.present?
    end

    log_info("Coin purchase request. user: ##{@user.id}, contract: ##{@contract.id}#{@buy_from_all_balance ? ', by all balance' : ''}#{@from_admin ? ", by admin: #{@created_by_user_id}" : ''}")

    if @buy_from_all_balance
      enough_balances(@contract_info['balances'])
    else
      enough_balances({@contract_info['currency'] => @contract_info['coin_price']})
    end

    require_user_promocode
    require_user_loyalty_program

    ActiveRecord::Base.transaction do
      currency_exchange if @buy_from_all_balance
      @payment = create_payment
      @contract.update_attribute(:payment_id, @payment.id)
      cpa_postbacks
      unless @disable_bonus
        create_payment_bonus
        create_promocode_bonus
        create_loyalty_program_bonus
        create_promocode_bounty
        if User.new.ability.can? :referral_system, :tokens
          create_referral_bounty_coins
          create_referral_user_coins
        end
        apply_promocode
      end
    end

    log_info("Coin purchase successful. user: ##{@user.id}, contract: ##{@contract.id}")
    SendTransactionToGoogleAnalyticsJob.perform_later(@contract.id)
    send_email
    { error:  false }

    rescue Services::Coin::CoinError => e
      log_error("Coin purchase failed. user: ##{@user.id}, contract: ##{@contract.id}. #{e.message}")
      { error: true, msg: e.message }

    rescue Services::Coin::CoinPromocodeError => e
      log_error("Coin purchase failed. user: ##{@user.id}, contract: ##{@contract.id}. #{e.message}")
      { error: true, msg: e.message}
  end

  private

  def cpa_postbacks
    payments_count = Payment.by_type(Payment::PAYMENT_TYPE_PURCHASE).by_user(@user.id).not_system.completed.count
    action         = payments_count == 1 ? ::CpaPostback::ACTION_BUY_TOKEN_FIRST : ::CpaPostback::ACTION_BUY_TOKEN_NON_FIRST
    cpa_params     = {
      token_amount:   @payment.iso_coin_amount,
      amount: Services::Coin::CurrencyToCurrencyConverter.new(
        @payment.amount_buyer,
        @payment.currency_origin,
        ExchangeRate::DEFAULT_CURRENCY
      ).call,
      transaction_id: @payment.id,
      status:         Payment::PAYMENT_STATUS_COMPLETED
    }

    SendCpaPostbackJob.perform_later(action, @user.id, cpa_params)
    SendCpaPostbackJob.perform_later(::CpaPostback::ACTION_BUY_TOKEN, @user.id, cpa_params)
  end

  def create_payment
    payment                           = Payment.new
    payment.user_id                   = @user.id
    payment.payment_type              = Payment::PAYMENT_TYPE_PURCHASE
    payment.currency_origin           = @contract_info['currency']
    payment.currency_buyer            = @contract_info['currency']
    payment.amount_origin             = @contract_info['coin_price']
    payment.amount_buyer              = @contract_info['coin_price']
    payment.iso_coin_amount           = @contract_info['coin_amount']
    payment.iso_coin_rate             = @contract_info['coin_rate']
    payment.ico_currency_amount       = @contract_info['ico_currency_amount']
    payment.ico_currency              = @contract_info['ico_currency']
    payment.created_by_user_id        = @created_by_user_id if @from_admin
    payment.description               = generate_payment_description
    payment.promocodes_users_id       = @user_promocode.id if @user_promocode.present?
    payment.assign_attributes(Services::SystemInfo::RequestInfo.new(@request).call) if @request.present?

    payment.save!
    payment
  end

  def create_payment_bonus
    return if @contract_info['coin_amount_bonus'].blank? || @contract_info['coin_amount_bonus'].to_f <= 0
    payment                           = Payment.new
    payment.user_id                   = @user.id
    payment.parent_payment_id         = @payment.id
    payment.payment_type              = Payment::PAYMENT_TYPE_BUY_TOKEN_BONUS
    payment.iso_coin_amount           = @contract_info['coin_amount_bonus'].to_f
    payment.description               = "Buy token bonus"
    payment.save!
    payment
  end

  def create_promocode_bonus
    return if @user_promocode.blank? || @contract_info['coin_amount_bonus_promocode'].blank? || @contract_info['coin_amount_bonus_promocode'].to_f <= 0

    payment                           = Payment.new
    payment.user_id                   = @user.id
    payment.parent_payment_id         = @payment.id
    payment.payment_type              = Payment::PAYMENT_TYPE_PROMOCODE_BONUS
    payment.promocodes_users_id       = @user_promocode.id
    payment.iso_coin_amount           = @contract_info['coin_amount_bonus_promocode'].to_f
    payment.description               = @user_promocode.promocode.is_promo_token ? 'Promo token bonus' : "Promo code bonus: #{@user_promocode.promocode.code}."

    payment.save!
    payment
  end


  def create_promocode_bounty
    return if @user_promocode.blank? || @user_promocode.promocode.blank? || @user_promocode.promocode.owner.blank?
    bonus = coin_floor(@payment.iso_coin_amount * @user_promocode.promocode.owner_bonus / 100.0)
    return if bonus <= 0

    payment   = Payment.new({
      iso_coin_amount:     bonus,
      user_id:             @user_promocode.promocode.owner_id,
      parent_payment_id:   @payment.id,
      payment_type:        Payment::PAYMENT_TYPE_PROMOCODE_BOUNTY,
      promocodes_users_id: @user_promocode.id,
      referral_user_id:    @payment.user_id,
      description:         @user_promocode.promocode.is_promo_token ? 'Promo token owner bonus' : "Promo code owner bonus: #{@user_promocode.promocode.code}"
    })

    payment.save!
    payment
  end

  def create_loyalty_program_bonus
    return if @loyalty_program_user.blank? || @contract_info['coin_amount_bonus_loyalty_program'].blank?
    bonus = coin_floor(@contract_info['coin_amount_bonus_loyalty_program'])
    return if bonus <= 0

    payment                           = Payment.new
    payment.user_id                   = @user.id
    payment.parent_payment_id         = @payment.id
    payment.payment_type              = Payment::PAYMENT_TYPE_LOYALTY_BONUS
    payment.iso_coin_amount           = bonus
    payment.description               = "Loyalty program bonus: #{@loyalty_program_user.loyalty_program.name}."
    payment.bonus_percent             = @loyalty_program_user.loyalty_program.bonus_percent

    payment.save!
    payment
  end

  def create_referral_bounty_coins
    system_referral_parameter = @config_parameters['user.referral_bonus_percent']
    return if system_referral_parameter.blank?

    user = @payment.user
    level = 0
    system_referral_parameter.each_with_index do |bonus_percent, i|
      user = user.referral
      break if user.blank?

      user_referral_parameter = UserParameter.get_user_parameter(user, 'user.referral_bonus_percent')
      bonus_percent = user_referral_parameter[i] if user_referral_parameter.count == system_referral_parameter.count

      level += 1
      bonus = coin_floor(@payment.iso_coin_amount * bonus_percent / 100.0)
      next if bonus <= 0
      Payment.create!(
        iso_coin_amount:    bonus,
        user_id:            user.id,
        parent_payment_id:  @payment.id,
        payment_type:       Payment::PAYMENT_TYPE_REFERRAL_BOUNTY,
        referral_user_id:   @user.id,
        description:        "Referral bounty bonus. Level #{level}",
        referral_level:     level,
        bonus_percent:      bonus_percent
      )
    end
  end

  def create_referral_user_coins
    return if @user.referral_id.blank?
    bonus_percent = UserParameter.get_user_parameter(@user, 'user.referral_user_bonus_percent')
    return if bonus_percent <= 0
    bonus = coin_floor(@payment.iso_coin_amount * bonus_percent / 100)
    return if bonus <= 0

    Payment.create!({
      iso_coin_amount:    bonus,
      user_id:            @payment.user.id,
      parent_payment_id:  @payment.id,
      payment_type:       Payment::PAYMENT_TYPE_REFERRAL_USER,
      bonus_percent:      bonus_percent
    })
  end

  def send_email
    PaymentsMailer.message_coin_payment_notification(@payment.id).deliver_later
  end

  def enough_balances(balances)
    balances.each do |currency, value|
      raise Services::Coin::CoinError.new("You do not have enough coins on your #{currency} balance") if currency_floor(Payment.balances_by_user_currency(@user, currency), currency) < currency_floor(value.to_f, currency)
    end
  end

  def currency_exchange
    @contract_info['balances'].each do |currency, amount|
      next if currency == @contract_info['currency']
      create_exchange_purchase_payment(amount, currency)
    end
    balance_amount = @contract_info['balances'][@contract_info['currency']].present? ? @contract_info['coin_price'].to_f - @contract_info['balances'][@contract_info['currency']].to_f : @contract_info['coin_price']
    create_exchange_balance_payment(balance_amount, @contract_info['currency']) if balance_amount > 0
  end

  def create_exchange_purchase_payment(amount, currency)
    payment                           = Payment.new
    payment.user_id                   = @user.id
    payment.payment_type              = Payment::PAYMENT_TYPE_PURCHASE
    payment.currency_origin           = currency
    payment.currency_buyer            = currency
    payment.amount_origin             = amount
    payment.amount_buyer              = amount
    payment.iso_coin_amount           = 0
    payment.system                    = true
    payment.save!
    payment
  end

  def create_exchange_balance_payment(amount, currency)
    payment                           = Payment.new
    payment.user_id                   = @user.id
    payment.payment_type              = Payment::PAYMENT_TYPE_BALANCE
    payment.currency_origin           = currency
    payment.currency_buyer            = currency
    payment.amount_origin             = amount
    payment.amount_buyer              = amount
    payment.system                    = true
    payment.save!
    payment
  end

  def require_user_promocode
    if @contract_info['promocode_user'].present?
      @user_promocode = PromocodesUser.find_by(id: @contract_info['promocode_user'])
      raise Services::Coin::CoinPromocodeError.new(I18n.t('promocode.not_exist')) if @user_promocode.blank?
      raise Services::Coin::CoinPromocodeError.new(I18n.t('promocode.already_used')) if @user_promocode.used_at.present?
      raise Services::Coin::CoinPromocodeError.new(I18n.t('promocode.not_valid')) unless @user_promocode.promocode.promocode_valid?
      raise Services::Coin::CoinPromocodeError.new(I18n.t('promocode.not_actual')) unless @user_promocode.property_actual?(@contract_info['coin_amount'], @contract_info['ico_currency_rate'])
      check_promo_token
    end
  end

  def require_user_loyalty_program
    if @contract_info['loyalty_program_user'].present?
      @loyalty_program_user = LoyaltyProgramsUser.find_by(id: @contract_info['loyalty_program_user'])
      raise Services::Coin::CoinPromocodeError.new(I18n.t('loyalty_program.not_exist')) if @loyalty_program_user.blank?
      raise Services::Coin::CoinPromocodeError.new(I18n.t('loyalty_program.not_actual')) unless @loyalty_program_user.actual?
    end
  end

  def check_promo_token
    if @user_promocode.promocode.is_promo_token?
      raise Services::Coin::CoinPromocodeError.new(I18n.t('promocode.promotoken.not_enabled')) unless Promocode.promo_token_enabled?
      raise Services::Coin::CoinPromocodeError.new(I18n.t('promocode.promotoken.not_enough_promo_tokens')) unless TokenTransaction.enough_promo_token_balance(@user.id)
    end
  end

  def generate_payment_description
    return @payment_description if @payment_description.present?
    if @user_promocode.present?
      return "Tokens purchase. Promo Token used." if @user_promocode.promocode.is_promo_token
      return "Tokens purchase. Promo code: #{@user_promocode.promocode.code}."
    end
    nil
  end

  def apply_promocode
    return if @user_promocode.blank?

    duplicate = @user_promocode.dup
    @user_promocode.update_columns(transaction_id: @payment.id, used_at: Time.current)
    @user_promocode.promocode.increment!(:num_used)

    duplicate.promocode_property = @user_promocode.promocode.property
    duplicate.save! if @user_promocode.promocode.can_duplicate?

    if @user_promocode.promocode.is_promo_token?
      Services::Token::PromoTokensPurchaseTransactionCreator.new(@user, @payment).call
    end
  end
end