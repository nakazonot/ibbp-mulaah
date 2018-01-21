class AddMultiplicyToParams < ActiveRecord::Migration[5.1]
  def change
    Parameter.create(
      [
        { name: 'coin.precision', value: 2, description: 'Number of decimal places for token' },
        { name: 'coin.currency_precision', value: 4, description: 'Number of decimal places for currency' }
      ]
    )
  end
end
