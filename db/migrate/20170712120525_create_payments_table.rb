class CreatePaymentsTable < ActiveRecord::Migration[5.1]
  def change
    create_table :payments do |t|
      t.references :user, index: true, foreign_key: true
      t.string     :transaction_id, null: false
      t.string     :currency_origin, null: false
      t.string     :currency_buyer, null: false
      t.decimal    :amount_origin, null: false, precision: 30, scale: 10
      t.decimal    :amount_buyer, null: false, precision: 30, scale: 10
      t.float      :iso_coin_bonus, null: true, default: 0
      t.decimal    :iso_coin_amount_origin, null: false, precision: 30, scale: 10
      t.decimal    :iso_coin_amount, null: false, precision: 30, scale: 10
    end
  end
end
