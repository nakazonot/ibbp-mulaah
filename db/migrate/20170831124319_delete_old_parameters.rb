class DeleteOldParameters < ActiveRecord::Migration[5.1]
  def change
    Parameter.where(
      name: %w[user.eth_payment_address coin.min_payment_amount_rate]
    ).destroy_all
  end
end
