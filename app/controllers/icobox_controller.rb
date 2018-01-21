class IcoboxController < ApplicationController
  include Concerns::Currency

  before_action :authenticate_user!, except: [:index, :close_ico]
  before_action :check_ico, except: [:close_ico]

  def index
    update_ga_client_id(current_user) if user_signed_in?
    prepare_for_view
  end

  def close_ico
    authorize!(:ico_closed, :ico)
    prepare_for_view
  end

  def ajax_coin_price
    authorize!(:show_ico_info, :user)
    result = Services::Calculations::CoinsToPrice.new(current_user, params[:coin_amount], params[:use_promocode].present? ? true : false).call
    ajax_ok(CoinPriceFormatter.new(result).view_data)
  end

  def ajax_coin_for_total
    authorize!(:show_ico_info, :user)
    result = Services::Calculations::PriceToCoins.new(current_user, params[:amount]).call
    ajax_ok(CoinPriceForTotalFormatter.new(result).view_data)
  end

  def ajax_get_address
    authorize!(:show_ico_info, :user)
    authorize!(:make_deposits, :stage)
    return ajax_error('Invalid currency') unless Parameter.available_currencies.keys.include?(params[:currency])
    address = Services::Coin::PaymentSystemAddressGetter.new(user: current_user, currency: params[:currency]).call
    return ajax_error(error: I18n.t('payment_address.deposit.can_not_get_address')) if address.nil?
    ajax_ok(get_address_hash(address))
  end

  def ajax_coins_for_all_balances
    authorize!(:show_ico_info, :user)
    result = Services::Calculations::CoinsForAllDeposits.new(current_user).call
    ajax_ok(CoinPriceForAllBalancesFormatter.new(result).view_data)
  end

  def ajax_buy_coins
    authorize!(:show_ico_info, :user)
    authorize!(:buy_tokens, :stage)
    return ajax_error({error: 'Invalid currency'}) unless Parameter.available_currencies.keys.include?(params[:currency])
    contract = Services::Coin::ContractCreator.new(contract_creator_params, current_user).call
    return ajax_error(contract) if contract[:error].present?

    ajax_ok(CoinBuyFormatter.new(contract, contract_agreement_path(contract.uuid, format: :pdf)).view_data)
  end

  def ajax_generate_invoice
    authorize!(:show_ico_info, :user)
    authorize!(:make_deposits, :stage)

    invoice_form = Forms::Invoice::CreateForm.new(create_invoice_params)
    if invoice_form.valid?
      invoice = Services::Invoiced::InvoiceCreator.new(invoice_form.attributes, current_user).call
      return ajax_ok({ pdf_url: invoice.pdf_url }) if invoice.present? && invoice.persisted?
    else
      return ajax_error({ error: 'valid_error', messages: invoice_form.errors.full_messages })
    end

    ajax_error({ error: t('errors.messages.invoice_creation') })
  end

  def ajax_contract_accept
    authorize!(:buy_tokens, :stage)
    contract = BuyTokensContract.find(params[:contract_id])
    authorize!(:sign_contract, contract)
    service_coin_creator = Services::Coin::CoinCreator.new(contract, request: request).call

    return ajax_error(msg: service_coin_creator[:msg]) if service_coin_creator[:error]

    flash[:notice] = 'The purchase of tokens was successful'
    ajax_ok(AcceptModalBuyCoinsFormatter.new([contract]).view_data.first)
  end

  private

  def prepare_for_view
    @bonus_preference               = @config_parameters['bonuses_percent']
    @available_currencies           = Parameter.available_currencies
    @min_payment_amount_by_currency = Parameter.min_payment_amount_by_currency
    @total_ico_currency_amount      = Payment.calc_total_ico_currency_amount
    @amount_of_purchased_tokens     = Payment.cached_total_amount_tokens

    return unless user_signed_in?

    invoice_customer = InvoiceCustomer.find_by(user_id: current_user.id)
    if invoice_customer.present?
      @invoice_form = Forms::Invoice::CreateForm.new(invoice_customer.attributes.symbolize_keys.slice(:full_name, :country, :state, :postal_code, :city, :address, :phone).merge(email: current_user.email))
    else
      @invoice_form = Forms::Invoice::CreateForm.new(phone: current_user.phone, full_name: current_user.name, email: current_user.email)
    end
    if ENV['GOOGLE_TAG_MANAGER'].present?
      contracts_to_gtm    = BuyTokensContract.by_user(current_user.id).send_to_gtm
      gon.push({ gtm_contracts: AcceptModalBuyCoinsFormatter.new(contracts_to_gtm).view_data })
      contracts_to_gtm.update_all(send_transaction_to_gtm: false)
    end
    @user_balances        = Payment.balances_by_user(current_user)
    @user_totals          = Payment.user_totals(current_user.id)
    @promo_token_balance  = TokenTransaction.promo_token_balance_by_user(current_user.id) if can?(:promo_token_enabled, :ico)
    @min_coin_for_payment = min_payment_coins_amount
    @bonus_referral       = current_user.is_referral? ?
                              UserParameter.get_user_parameter(current_user, 'user.referral_user_bonus_percent') :
                              0.0
    @loyalty_program_bonus = Services::LoyaltyProgram::ChoiceForUser.new(current_user).call
    @user_currencies_for_purchase = @user_balances.keys & @available_currencies.keys
    get_user_addresses
    gon.push({
      min_coin_for_payment: min_payment_coins_amount,
      coin_precision:       @config_parameters['coin.precision'],
      currency_precision:   @config_parameters['coin.currency_precision'],
      usd_precision:        @config_parameters['coin.usd_precision'],
      default_currency:     ExchangeRate::DEFAULT_CURRENCY,
      gtm_enabled:          ENV['GOOGLE_TAG_MANAGER'].present?,
      kyc_passed:           current_user.kyc_result
    })
  end

  def get_user_id
    user_signed_in? ? current_user.id : nil
  end

  def get_user_addresses
    @user_addresses = {}
    current_user.available_payment_addresses.each do |address|
      @user_addresses[address.currency] = get_address_hash(address)
    end
  end

  def get_address_hash(address)
    {
      address: address.payment_address,
      pubkey: (address.pubkey.present? && address.currency == 'NXT' ) ? "pubkey: #{address.pubkey}" : nil,
      dest_tag: address.dest_tag.nil? ? address.dest_tag : "dest_tag: #{address.dest_tag}",
      payment_system: address.payment_system
    }
  end

  def create_invoice_params
    params.require(:forms_invoice_create_form).permit(
      :amount, :full_name, :country, :state, :city, :address, :postal_code, :phone
    )
  end

  def min_payment_coins_amount
    @config_parameters['coin.min_payment_coins_amount']
  end

  def contract_creator_params
    params.permit(:buy_from_all_balance, :currency, :coin_price, :coin_amount, :purchase_agreement)
  end
end
