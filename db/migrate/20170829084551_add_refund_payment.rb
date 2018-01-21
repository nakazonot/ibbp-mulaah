class AddRefundPayment < ActiveRecord::Migration[5.1]
  disable_ddl_transaction!

  def change
    execute <<-SQL
      ALTER TYPE "payment_type" ADD VALUE 'refund';
    SQL
  end
end
