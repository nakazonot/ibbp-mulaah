class AddTranslationForAsideBlocks < ActiveRecord::Migration[5.1]
  def change
    Translation.create(
      locale: 'en',
      key: 'aside.token_balance_title',
      value: 'My %{coin_name} Tokens',
      interpolations: %w[coin_name, coin_tiker]
    )
    Translation.create(
      locale: 'en',
      key: 'aside.referral_token_balance_title',
      value: 'My %{coin_name} Referral Tokens',
      interpolations: %w[coin_name, coin_tiker]
    )
    Translation.create(
      locale: 'en',
      key: 'aside.token_price_title',
      value: '%{coin_name} Token Price',
      interpolations: %w[coin_name, coin_tiker]
    )
  end
end
