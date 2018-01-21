class AddPromocodeBonusTypeToPayment < ActiveRecord::Migration[5.1]
  disable_ddl_transaction!

  def change
    execute <<-SQL
      ALTER TYPE "payment_type" ADD VALUE 'promocode_bonus';
    SQL
  end
end
