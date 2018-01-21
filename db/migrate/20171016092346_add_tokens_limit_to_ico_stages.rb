class AddTokensLimitToIcoStages < ActiveRecord::Migration[5.1]
  def change
    add_column :ico_stages, :tokens_limit, :integer, limit: 8, null: true
  end
end
