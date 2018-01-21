class AddAutoCoinPaymentParameter < ActiveRecord::Migration[5.1]
  def change
    Parameter.create(
      name: 'system.auto_convert_balance_to_tokens', 
      value: '0', 
      description: 'Автоконвертация зачисленных денег в токены (0 - выкл/ 1 - вкл)'
    )
  end
end