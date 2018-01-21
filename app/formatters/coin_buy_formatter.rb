class CoinBuyFormatter
  include Concerns::Currency

  def initialize(contract, path)
    @contract = contract
    @path = path
  end

  def view_data
    {
      contract: {
        id: @contract.id,
        info: {
          currency:         @contract.info['currency'],
          coin_amount:      coins_number_format(@contract.info['coin_amount']),
          coin_rate:        @contract.info['coin_rate'],
          coin_bonus_total: coins_number_format(calc_bonus_total)
        }
      },
      contract_path: @path
    }
  end

  def calc_bonus_total
    bonus   = @contract.info['coin_amount_bonus']
    bonus  += @contract.info['coin_amount_bonus_promocode'] if @contract.info['coin_amount_bonus_promocode'].present?
    bonus  += @contract.info['coin_amount_bonus_referral_user'] if @contract.info['coin_amount_bonus_referral_user'].present?
    bonus  += @contract.info['coin_amount_bonus_loyalty_program'] if @contract.info['coin_amount_bonus_loyalty_program'].present?
    bonus
  end

end
