class ChangeParamsDescriptionFixed < ActiveRecord::Migration[5.1]
  def change
    description_rus = {
      'ico.date_start' => 'Start date of ICO (yyyy-mm-dd hh:mm:ss)',
      'ico.date_end' => 'End date of ICO (yyyy-mm-dd hh:mm:ss)',
      'ico.bonus_percent' => 'Bonus amount during ICO',
      'presale.date_start' => 'Start date of Pre-sale (yyyy-mm-dd hh:mm:ss)',
      'presale.date_end' => 'End date of Presale (yyyy-mm-dd hh:mm:ss)',
      'presale.bonus_percent'=> 'Bonus amount during Presale',
      'user.eth_payment_address'=> 'ETH Wallet to receive payments',
      'links.ico_site'=> 'Link to the button "ICO site"',
      'links.white_paper'=> 'Link to the button "White paper"',
      'links.token_contact'=> 'Link to the button "Token contract"',
      'links.slack'=> 'Link to ICO`s Slack channel',
      'links.telegram'=> 'Link to ICO`s Telegram channel',
      'links.we_chat'=> 'Link to ICO`s WeChat channel',
      'coin.name'=> 'ICO\'s currency name (e.g., ExampleCoin)',
      'coin.tiker'=> 'ICO\'s ticker name (e.g., EXCN)',
      'coin.rate'=> 'Coin exchange value',
      'available_currencies'=> 'Available currencies of the issuer',
      'user.referral_bonus_percent'=> 'Bonus amount for participants of the referral program',
      'ico.support_email'=> 'Link to email of ICO\'s tech support',
      'links.faq'=> 'Link to ICO FAQ',
      'coin.investments_volume'=> 'Volume of investments ICO',
      'coin.min_payment_amount'=> 'Minimum payment amount',
      'coin.min_payment_amount_rate'=> 'Exchange rate for payments, that are less than the minimum payment amount',
      'system.enable_user_activation_code'=> 'Enabling of activation the accounts of users via activation link (1 — enable option, 0 — disable option)',
      'system.skip_eth_wallet_input'=> 'Allow users to skip the input of the ETH wallet (1 - allow, 0 — disallow)',
      'system.skip_totals_block_date_to'=> 'Date of the beginning of the display of the amount \"Funds raised thus far\" (yyyy-mm-dd hh:mm:ss)',
      'links.license_agreement'=> 'Link to Purchase agreement',
      'coin.rate_currency'=> 'The currency in which the coin rate is set',
      'system.current_ico_stage'=> 'Current stage of ICO',
      'coin.ico_tokens_volume'=> 'Volume of ICO tokens',
      'invoiced.max_amount_for_transfer'=> 'Maximum amount of payment via Invoiced',
      'invoiced.min_amount_for_transfer'=> 'Minimum amount of payment via Invoiced',
      'system.auto_convert_balance_to_tokens'=> 'Enable the autoconvertaition of received payment to tokens (0 — disable, 1 — enable)',
      'links.logo'=> 'Link to ICO Logo',
      'system.authorization_key'=> 'API-key for obtaining the main info about ICO',
      'system.buy_tokens_agreement_enabled'=> 'Displaying a contract for the purchase of tokens (0 — turn off, 1 — turn on)',
      'user.referral_user_bonus_percent'=> 'Bonus percent for referral link follower',
      'user.referral_bonus_percent'=> 'Bonus percent for referral link subscriber'
    }

    Parameter.all.each do |parameter|
      next unless description_rus.has_key?(parameter.name)
      parameter.update_attributes(description: description_rus[parameter.name])
    end
  end
end