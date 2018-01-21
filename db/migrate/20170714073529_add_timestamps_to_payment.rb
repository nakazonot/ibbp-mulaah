class AddTimestampsToPayment < ActiveRecord::Migration[5.1]
  def change
    add_timestamps :payments, null: true
  end
end
