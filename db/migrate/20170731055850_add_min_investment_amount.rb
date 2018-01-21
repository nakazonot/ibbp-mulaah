class AddMinInvestmentAmount < ActiveRecord::Migration[5.1]
  def change
    Parameter.create(
      [
        { name: 'coin.min_payment_amount_usd', description: 'Минимальная сумма платежа(USD)'},
        { name: 'coin.min_payment_amount_to_usd_rate', description: 'Курс валюты по отношению к USD для платежа, меньше минимального'}
      ]
    )
  end
end
