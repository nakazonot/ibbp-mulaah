class CreateIcoStages < ActiveRecord::Migration[5.1]
  def change
    create_table :ico_stages do |t|
      t.string   :name, null: false
      t.datetime :date_start, null: false
      t.datetime :date_end, null: false
      t.float    :coin_price, null: false
      t.decimal  :min_tokens_for_buy, precision: 30, scale: 10
      t.float    :bonus_percent

      t.timestamps  null: false
    end
  end
end
