namespace :coin do
  desc "Buy tokens to all users (filter users: BALANCE_LOWER_MIN_PAYMENT=true;KYC_PASSED=true)"
  task buy_tokens_to_all_users: :environment do
    Rails.cache.delete(:config_parameters)
    parameters = Parameter.get_all

    User.find_each(batch_size: 200) do |user|
      data = Payment.calc_coins_from_all_balances_by_promocode(user)
      next if ENV['BALANCE_LOWER_MIN_PAYMENT'].to_b && data[:coin_amount] >= parameters['coin.min_payment_coins_amount']
      next if ENV['KYC_PASSED'].to_b && (user.kyc_result.blank? || !user.kyc_result)

      if data[:coin_amount] == 0
        puts "User ##{user.id} - Balance is not enough to buy tokens".yellow
        next
      end

      if data[:currencies].keys.size == 1
        params = {
          buy_from_all_balance: 'false',
          'coin_amount'      => data[:coin_amount],
          'coin_price'       => data[:currencies].first.second,
          'currency'         => data[:currencies].first.first,
        }
      else
        params = {
          buy_from_all_balance: 'true',
          'coin_amount'      => data[:coin_amount],
          'coin_price'       => data[:coin_price],
          'currency'         => data[:currency]
        }
      end

      contract = Services::Coin::ContractCreator.new(params, user, from_admin: true).call
      if contract[:error].present?
        puts "User ##{user.id} - ERROR: #{contract[:error]}".red
        next
      end

      payment = Services::Coin::CoinCreator.new(contract, payment_description: 'Automatic purchase').call
      if payment[:error]
        puts "User ##{user.id} - ERROR: #{payment[:msg]}".red
        next
      end

      bonus_total = coin_floor(contract.info['coin_amount_bonus'].to_f +
        contract.info['coin_amount_bonus_promocode'].to_f + 
        contract.info['coin_amount_bonus_referral_user'].to_f + 
        contract.info['coin_amount_bonus_loyalty_program'].to_f)
      puts "User ##{user.id} - #{contract.info['coin_amount']} (+#{bonus_total} bonus) coins credited".green
    end
  end
end
