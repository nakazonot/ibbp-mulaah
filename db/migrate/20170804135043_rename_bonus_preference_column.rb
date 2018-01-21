class RenameBonusPreferenceColumn < ActiveRecord::Migration[5.1]
  def change
    rename_column :bonus_preferences, :max_investment_amount_usd, :max_investment_amount
  end
end
