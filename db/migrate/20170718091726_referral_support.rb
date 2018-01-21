class ReferralSupport < ActiveRecord::Migration[5.1]
  def change
    # Users table
    add_column :users, :referral_uuid, :string
    add_index  :users, [:referral_uuid], unique: true

    add_column :users, :referral_id, :integer
    add_foreign_key :users, :users, column: :referral_id

    # Setup referral bonus percent
    Parameter.create(
      name: 'user.referral_bonus_percent', value: 5, description: 'Размер бонуса по реферальной программе'
    )

    # create user tokens table
    execute <<-SQL
      CREATE TYPE user_iso_coin_create_type
      AS ENUM ('payment', 'referral');
    SQL

    create_table :user_ico_coins do |t|
      t.decimal    :coin_amount, null: false, precision: 30, scale: 10
      t.column     :create_type, :user_iso_coin_create_type, null: false, default: 'payment'
      t.references :user, index: true, foreign_key: true
      t.references :payment, null: true, index: true, foreign_key: true
      t.timestamps
    end

    # move data to user_tokens
    Payment.unscoped.find_each(batch_size: 200) do |payment|
      UserIcoCoin.create(
        coin_amount: payment.iso_coin_amount,
        create_type: UserIcoCoin::CREATE_TYPE_PAYMENT,
        user_id: payment.user_id,
        payment_id: payment.id,
        created_at: payment.created_at,
        updated_at: payment.updated_at,
      )
    end

    # generate referral_uid for existing users
    User.unscoped.find_each(batch_size: 200) do |user|
      user.update(referral_uuid: SecureRandom.hex(12))
    end
  end
end
