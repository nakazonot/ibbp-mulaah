class AddBuyTokensAgreementsTable < ActiveRecord::Migration[5.1]
  def change
    create_table :buy_tokens_contracts do |t|
      t.references :user, index: true, foreign_key: true
      t.json :info, null: false
      t.timestamps  null: false
    end
  end
end
