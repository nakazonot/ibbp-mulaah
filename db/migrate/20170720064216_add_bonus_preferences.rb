class AddBonusPreferences < ActiveRecord::Migration[5.1]
  def change
    create_table :bonus_preferences do |t|
      t.float       :max_investment_amount_usd, null: false
      t.float       :bonus_percent, null: false
      t.timestamps
    end
  end
end
