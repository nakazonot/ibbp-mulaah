class RenameRateParameters < ActiveRecord::Migration[5.1]
  def change
    Parameter.find_by(name: 'coin.to_usd_rate').update(name: 'coin.rate', description: 'Стоимость токена (курс)')
    Parameter.find_by(name: 'coin.price_display_currency').update(name: 'coin.rate_currency', description: 'Валюта, в которой устанавливается курс монеты')
    Parameter.find_by(name: 'coin.min_payment_amount_usd').update(name: 'coin.min_payment_amount')
    Parameter.find_by(name: 'coin.min_payment_amount_to_usd_rate').update(name: 'coin.min_payment_amount_rate', description: 'Курс валюты для платежей, меньше минимального')
    Parameter.find_by(name: 'coin.investments_volume').update(description: 'Объем целевых инвестиций')
  end
end
