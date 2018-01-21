class Services::Coin::AutoConverter
  def initialize(user_id)
    @user                 = User.find_by(id: user_id)
    @config_parameters    = Parameter.get_all
  end

  def call
    return if @user.blank?
    data = Payment.calc_coins_from_all_balances_by_promocode(@user)
    params = {
      buy_from_all_balance: 'true',
      coin_amount:          data[:coin_amount],
      coin_price:           data[:coin_price],
      currency:             data[:currency],
      purchase_agreement:   'true'
    }
    contract = Services::Coin::ContractCreator.new(params, @user, send_transaction_to_gtm: ENV['GOOGLE_TAG_MANAGER'].present?).call

    if contract[:error].blank?
      Services::Coin::CoinCreator.new(contract).call
    end
  end

end