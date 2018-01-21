class AddBonusTypeToPaymentType < ActiveRecord::Migration[5.1]
  disable_ddl_transaction!

  def change
    execute <<-SQL
      ALTER TYPE "payment_type" ADD VALUE 'buy_token_bonus' AFTER 'payment';
    SQL
  end
end
