class CreateRatesTable < ActiveRecord::Migration[5.1]
  def change
    create_table :exchange_rates do |t|
      t.string     :from
      t.string     :to
      t.float      :rate
      t.timestamps
    end
    add_index :exchange_rates, [:to, :from], unique: true
  end
end
