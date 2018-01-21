class ChangeUsdPrecision < ActiveRecord::Migration[5.1]
  def change
    Parameter.create(name: 'coin.usd_precision', value: 2, description: 'Number of decimal places for USD')
  end
end
