class PromoToken < ActiveRecord::Migration[5.1]
  def change
    execute <<-SQL
      CREATE TYPE payment_address_type AS ENUM ('deposit', 'promo_tokens');
    SQL
    add_column :payment_addresses, :address_type, :payment_address_type, null: false, default: 'deposit'

    add_column :promocodes, :is_promo_token, :boolean, null: false, default: false
    add_column :promocodes_users, :promo_token_transfer_id, :string, null: true
  end
end
