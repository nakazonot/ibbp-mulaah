class AddReferralSystemForBalance < ActiveRecord::Migration[5.1]
  disable_ddl_transaction!

  def change
    execute <<-SQL
      ALTER TYPE "payment_type" ADD VALUE 'referral_bonus_balance';
    SQL
    execute <<-SQL
      ALTER TYPE "payment_type" ADD VALUE 'referral_bounty_balance';
    SQL

    Parameter.create(name: 'user.referral_bonus_type', value: 'tokens', description: 'tokens/balance')
  end
end
