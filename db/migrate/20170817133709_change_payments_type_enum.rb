class ChangePaymentsTypeEnum < ActiveRecord::Migration[5.1]
  disable_ddl_transaction!

  def up
    execute <<-SQL
      ALTER TYPE payment_type ADD VALUE 'referral_user';
    SQL

    execute <<-SQL
      ALTER TYPE payment_type ADD VALUE 'referral_bounty';
    SQL
  end
end
