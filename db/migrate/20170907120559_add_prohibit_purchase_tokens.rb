class AddProhibitPurchaseTokens < ActiveRecord::Migration[5.1]
  def change
    add_column :ico_stages, :prohibit_purchase_tokens, :boolean, default: false
  end
end
