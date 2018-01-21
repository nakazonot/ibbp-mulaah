class ChangeColumnMinTokens < ActiveRecord::Migration[5.1]
  def change
    rename_column :ico_stages, :min_tokens_for_buy, :min_payment_amount
  end
end
