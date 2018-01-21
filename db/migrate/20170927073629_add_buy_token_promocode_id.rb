class AddBuyTokenPromocodeId < ActiveRecord::Migration[5.1]
  def change
    add_reference :ico_stages, :buy_token_promocode, index: true, foreign_key: { to_table: :promocodes }
  end
end
