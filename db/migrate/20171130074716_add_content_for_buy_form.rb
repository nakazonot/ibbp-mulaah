class AddContentForBuyForm < ActiveRecord::Migration[5.1]
  def change
    Translation.create([
      {
      	locale: 'en',
        key: 'main.step.buy_form.widgets_html',
        value: '',
        interpolations: %w[]
      },
      {
      	locale: 'en',
        key: 'main.step.buy_form.title',
        value: 'Buy %{coin_tiker} tokens',
        interpolations: %w[coin_tiker]
      },
      {
      	locale: 'en',
        key: 'main.step.buy_form.buttons.buy_now',
        value: 'BUY NOW',
        interpolations: %w[]
      },
    ])
  end
end