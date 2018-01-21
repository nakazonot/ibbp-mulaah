class AddAvailableCurrencyField < ActiveRecord::Migration[5.1]
  def change
    add_column :parameters, :is_readonly, :boolean, default: false
    Parameter.reset_column_information
    Parameter.create(
      [
        { name: Parameter::AVAILABLE_CURRENCIES_NAME, description: 'Доступные валюты у эмитента в системе CoinPayments', is_readonly: true },
      ]
    )
  end
end