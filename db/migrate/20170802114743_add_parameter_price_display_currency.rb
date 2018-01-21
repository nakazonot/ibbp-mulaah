class AddParameterPriceDisplayCurrency < ActiveRecord::Migration[5.1]
  def change
    Parameter.create(
      [
        { name: 'coin.price_display_currency', description: 'Валюта, в которой будет выводиться стоимость токенов', value: ExchangeRate::DEFAULT_CURRENCY},
      ]
    )
  end
end
