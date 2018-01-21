class AddTranslationsForWallets < ActiveRecord::Migration[5.1]
  def change
    Translation.create([
      {
      	locale: 'en',
        key: 'activerecord.attributes.user.eth_wallet',
        value: 'ETH Wallet',
        interpolations: nil
	  },{
      	locale: 'en',
        key: 'activerecord.attributes.user.btc_wallet',
        value: 'BTC Wallet',
        interpolations: nil
	  },{
      	locale: 'en',
        key: 'main.step.make_deposit.eth_wallet_missing_html',
        value: '<div class="alert alert-dismissible alert-warning">Please enter ETH wallet in <a href="%{profile_url}" class="link">your profile</a>.</div>',
        interpolations: %w[profile_url]
	  },{
      	locale: 'en',
        key: 'main.step.make_deposit.btc_wallet_missing_html',
        value: '<div class="alert alert-dismissible alert-warning">Please enter BTC wallet in <a href="%{profile_url}" class="link">your profile</a>.</div>',
        interpolations: %w[profile_url]
	  }
    ])
  end
end
