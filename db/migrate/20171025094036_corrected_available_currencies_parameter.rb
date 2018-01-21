class CorrectedAvailableCurrenciesParameter < ActiveRecord::Migration[5.1]
  def change
    available_currencies = Parameter.find_by(name: Parameter::AVAILABLE_CURRENCIES_NAME)
    if available_currencies.present? && available_currencies.value.present?
      result = {}
      JSON.parse(available_currencies.value).each do |c_symbol, c_name|
        result[c_symbol] = { name: c_name, payment_system: PaymentSystemType::COIN_PAYMENTS }
      end
      available_currencies.value = result.to_json
      available_currencies.save!
    end
  end
end
