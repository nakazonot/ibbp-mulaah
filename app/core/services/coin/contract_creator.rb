class Services::Coin::ContractCreator
  include Concerns::Currency

  def initialize(params, user, from_admin: false, disable_bonus: false, send_transaction_to_gtm: false)
    @params               = params.deep_dup.to_h.symbolize_keys
    @user                 = user
    @config_parameters    = Parameter.get_all
    @buy_from_all_balance = @params[:buy_from_all_balance].to_b
    @currency             = @buy_from_all_balance ? @config_parameters['coin.rate_currency'] : @params[:currency]
    @ico_currency_amount  = Services::Coin::CurrencyToCurrencyConverter.new(@params[:coin_price].to_f, @currency, @config_parameters['coin.rate_currency']).call
    @ico_coin_rate        = @ico_currency_amount / params[:coin_amount].to_f
    @coin_rate            = coin_rate_floor(@params[:coin_price].to_f / params[:coin_amount].to_f)
    @from_admin           = from_admin
    @promocode_user       = PromocodesUser.search_actual_promocode_by_user(@user.id, @params[:coin_amount].to_f, from_admin ? @ico_coin_rate : @config_parameters['coin.rate'])
    @promocode_user       = nil if from_admin && @promocode_user.present? && @promocode_user.promocode_property['discount_type'] == Promocode::DISCOUNT_TYPE_FIXED_PRICE
    @disable_bonus        = disable_bonus
    @send_transaction_to_gtm = send_transaction_to_gtm
  end

  def call
    return check_errors if check_errors.present?
    @contract = create_contract
    SendItemToGoogleAnalyticsJob.perform_later(@contract.id)
    @contract
  end

  private

  def create_contract
    info = {
      currency:            @currency,
      coin_amount:         coin_floor(@params[:coin_amount].to_f),
      coin_price:          currency_floor(@params[:coin_price].to_f, @currency),
      coin_rate:           @coin_rate,
      ico_currency:        @config_parameters['coin.rate_currency'],
      ico_currency_amount: currency_floor(@ico_currency_amount, @config_parameters['coin.rate_currency']),
      ico_currency_rate:   coin_rate_floor(@ico_coin_rate)
    }

    info[:balances]                           = Payment.calc_coins_from_all_balances(@user, @promocode_user)[:currencies] if @buy_from_all_balance
    unless @disable_bonus
      bonuses                                 = calc_bonuses
      info[:coin_amount_bonus]                = coin_floor(bonuses[:bonus_token])
      if User.new.ability.can? :referral_system, :tokens
        info[:coin_amount_bonus_referral_user]  = coin_floor(bonuses[:bonus_referral_user_token])
        info[:percent_bonus_referral_user]      = bonuses[:bonus_refferal_user_percent]
      end

      if @promocode_user.present?
        coin_amount_bonus_promocode           = coin_floor(bonuses[:bonus_promocode])
        info[:promocode_user]                 = @promocode_user.id
        info[:coin_amount_bonus_promocode]    = coin_amount_bonus_promocode if coin_amount_bonus_promocode > 0
      end

      loyalty_program_user = Services::LoyaltyProgram::ChoiceForUser.new(@user).call
      if loyalty_program_user.present?
        info[:loyalty_program_user] = loyalty_program_user.id
        info[:coin_amount_bonus_loyalty_program] = coin_floor(Services::Coin::CalcBonus.new(@params[:coin_amount].to_f, loyalty_program_user.loyalty_program.bonus_percent).amount_bonus)
      end
    end

    contract = BuyTokensContract.new(user_id: @user.id, info: info, send_transaction_to_gtm: @send_transaction_to_gtm)
    contract.save!(validate: false)
    contract
  end

  def check_errors
    return { error: 'Invalid currency' } unless Parameter.available_currencies.keys.include?(@currency)
    return { error: "You do not have enough funds on your #{@currency} balance" } unless enough_balance_by_currency?
    return nil if @from_admin
    return { error: 'The purchase agreement is not accepted' } unless purchase_agreement_accepted?
    return { error: "The cost of the coins has changed, please, try again" } unless coins_payment_valid?
    return { error: "You can't purchase amount of tokens less, than #{min_payment_coins_amount} during current period" } if @params[:coin_amount].to_f <= 0 || @params[:coin_amount].to_f < min_payment_coins_amount
    nil
  end

  def coins_payment_valid?
    if @buy_from_all_balance
      estimated_data = Payment.calc_coins_from_all_balances(@user, @promocode_user)
      return equal_currencies(@params[:coin_price].to_f, estimated_data[:coin_price], @currency) && equal_coins(@params[:coin_amount].to_f, estimated_data[:coin_amount])
    else
      estimated_price = currency_ceil(Services::Coin::ToCurrencyConverter.new(@params[:coin_amount], @currency, @promocode_user).call, @currency)
      return equal_currencies(@params[:coin_price].to_f, estimated_price, @currency)
    end
  end

  def calc_bonuses
    bonuses = BonusPreference.get_bonus_preference(@user.id, coin_amount: @params[:coin_amount].to_f, promocode_user: @promocode_user, ico_coin_rate: @ico_coin_rate)
    {
      bonus_referral_user_token:   Services::Coin::CalcBonus.new(@params[:coin_amount].to_f, bonuses[:bonus_refferal_user_percent]).amount_bonus,
      bonus_refferal_user_percent: bonuses[:bonus_refferal_user_percent],
      bonus_token:                 Services::Coin::CalcBonus.new(@params[:coin_amount].to_f, bonuses[:bonus_percent]).amount_bonus,
      bonus_promocode:             Services::Coin::CalcBonus.new(@params[:coin_amount].to_f, bonuses[:bonus_promocode]).amount_bonus
    }
  end

  def enough_balance_by_currency?
    return true if @buy_from_all_balance
    currency_floor(Payment.balances_by_user_currency(@user, @currency), @currency) >= currency_floor(@params[:coin_price].to_f, @currency)
  end

  def min_payment_coins_amount
    @config_parameters['coin.min_payment_coins_amount']
  end

  def purchase_agreement_accepted?
    return true if get_purchase_agreements.blank?
    @params[:purchase_agreement].to_b
  end
end