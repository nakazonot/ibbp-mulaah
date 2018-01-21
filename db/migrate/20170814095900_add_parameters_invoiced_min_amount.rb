class AddParametersInvoicedMinAmount < ActiveRecord::Migration[5.1]
  def change
    Parameter.create(name: 'invoiced.min_amount_for_transfer', value: 10000, description: 'Минимальная сумма платежа через систему Invoiced')
    Parameter.create(name: 'invoiced.max_amount_for_transfer', value: 100000000, description: 'Максимальная сумма платежа через систему Invoiced')
  end
end
