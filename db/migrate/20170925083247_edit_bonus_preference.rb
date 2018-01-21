class EditBonusPreference < ActiveRecord::Migration[5.1]
  def change
    rename_column :bonus_preferences, :max_investment_amount, :min_investment_amount
    add_reference :bonus_preferences, :ico_stage, index: true, foreign_key: true, null: true
  end
end
