class AddUsdTranslationFragment < ActiveRecord::Migration[5.1]
  def change
    Translation.create(
      locale: 'en',
      key: 'main.step.make_deposit.usd_tab_title',
      value: 'USD'
    )
  end
end
