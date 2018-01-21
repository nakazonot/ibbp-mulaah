class AddUuidToBuyTokensContract < ActiveRecord::Migration[5.1]
  def change
    add_column :buy_tokens_contracts, :uuid, :string
    add_index  :buy_tokens_contracts, :uuid, unique: true
  end
end
