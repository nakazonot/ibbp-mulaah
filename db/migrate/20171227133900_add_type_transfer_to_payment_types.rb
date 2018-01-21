class AddTypeTransferToPaymentTypes < ActiveRecord::Migration[5.1]
  disable_ddl_transaction!

  def change
    execute <<-SQL
      ALTER TYPE payment_type ADD VALUE 'transfer_tokens';
    SQL
  end
end
