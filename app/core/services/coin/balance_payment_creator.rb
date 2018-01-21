class Services::Coin::BalancePaymentCreator
  include TrackingLabels

  def initialize(params, status: nil, created_by_user: nil, request: nil, payment: nil)
    @params             = params.deep_dup
    @user               = params[:user]
    @config_parameters  = Parameter.get_all
    @request            = request
    @created_by_user    = created_by_user
    @disable_bonus      = params[:disable_bonus].present? ? params[:disable_bonus] : false
    @status             = status.nil? ? Payment::PAYMENT_STATUS_COMPLETED : status
    @payment            = payment
    raise "Payment user not found! params: #{@params.to_json}" if @user.blank?
  end

  def call
    return @payment if @payment.present? && (@payment.completed? || @status == Payment::PAYMENT_STATUS_PENDING)
    ActiveRecord::Base.transaction do
      create_payment
      if @status == Payment::PAYMENT_STATUS_COMPLETED
        cpa_postbacks

        if !@disable_bonus && User.new.ability.can?(:referral_system, :balance)
          create_referral_bonus_payment
          create_referral_bounty_payment
        end
      end
    end
    @payment
  end

  private

  def cpa_postbacks
    deposits_count = Payment.by_type(Payment::PAYMENT_TYPE_BALANCE).by_user(@user.id).not_system.completed.count
    action         = deposits_count == 1 ? ::CpaPostback::ACTION_DEPOSIT_FIRST : ::CpaPostback::ACTION_DEPOSIT_NON_FIRST
    cpa_params     = {
      amount: Services::Coin::CurrencyToCurrencyConverter.new(
        @payment.amount_buyer,
        @payment.currency_origin,
        ExchangeRate::DEFAULT_CURRENCY
      ).call,
      transaction_id: @payment.id,
      status: Payment::PAYMENT_STATUS_COMPLETED
    }

    SendCpaPostbackJob.perform_later(action, @user.id, cpa_params)
    SendCpaPostbackJob.perform_later(::CpaPostback::ACTION_DEPOSIT, @user.id, cpa_params)
  end

  def create_payment
    return @payment.update_column(:status, @status) if @payment.present?
    @payment = Payment.create!({
      user_id:            @user.id,
      payment_type:       Payment::PAYMENT_TYPE_BALANCE,
      payment_system:     @params[:payment_system],
      transaction_id:     @params[:transaction_id],
      currency_origin:    @params[:currency],
      currency_buyer:     @params[:currency],
      amount_origin:      @params[:amount],
      amount_buyer:       @params[:amount],
      description:        @params[:description].present? ? @params[:description] : nil,
      status:             @status,
      created_by_user_id: @created_by_user&.id
    }.merge(Services::SystemInfo::RequestInfo.new(@request).call))
  end

  def create_referral_bounty_payment
    return if @config_parameters['user.referral_bonus_percent'].blank?

    user = @payment.user
    level = 0
    @config_parameters['user.referral_bonus_percent'].each do |bonus_percent|
      user = user.referral
      break if user.blank?

      level += 1
      bonus = currency_floor(@payment.amount_buyer * bonus_percent / 100.0, @payment.currency_buyer)
      next if bonus <= 0
      Payment.create!(
        amount_buyer:       bonus,
        amount_origin:      bonus,
        currency_buyer:     @payment.currency_buyer,
        currency_origin:    @payment.currency_origin,
        user_id:            user.id,
        parent_payment_id:  @payment.id,
        payment_type:       Payment::PAYMENT_TYPE_REFERRAL_BOUNTY_BALANCE,
        referral_user_id:   @user.id,
        description:        "Referral bounty bonus. Level #{level}",
        referral_level:     level
      )
    end
  end

  def create_referral_bonus_payment
    return if @payment.user.referral_id.blank? || @config_parameters['user.referral_user_bonus_percent'].to_f <= 0
    bonus = currency_floor(@payment.amount_buyer * @config_parameters['user.referral_user_bonus_percent'].to_f / 100.0, @payment.currency_buyer)
    return if bonus <= 0

    Payment.create!(
      user_id:            @payment.user.id,
      currency_buyer:     @payment.currency_buyer,
      currency_origin:    @payment.currency_origin,
      amount_origin:      bonus,
      amount_buyer:       bonus,
      parent_payment_id:  @payment.id,
      payment_type:       Payment::PAYMENT_TYPE_REFERRAL_BONUS_BALANCE
    )
  end

end