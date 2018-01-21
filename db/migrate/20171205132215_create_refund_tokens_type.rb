class CreateRefundTokensType < ActiveRecord::Migration[5.1]
  disable_ddl_transaction!

  def up
    execute <<-SQL
      ALTER TYPE payment_type ADD VALUE 'refund_tokens';
    SQL
  end
end
