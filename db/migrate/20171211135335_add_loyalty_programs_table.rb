class AddLoyaltyProgramsTable < ActiveRecord::Migration[5.1]
  disable_ddl_transaction!

  def change
    execute <<-SQL
      ALTER TYPE payment_type ADD VALUE 'loyalty_bonus';
    SQL
    create_table :loyalty_programs do |t|
      t.string   :contract, null: false
      t.string   :name, null: false
      t.decimal  :bonus_percent, precision: 30, scale: 10, null: false
      t.decimal  :min_amount, precision: 30, scale: 10, null: false
      t.integer  :lifetime_hour, null: true
      t.boolean  :is_enabled, null: false, default: false
      t.timestamps
      t.datetime :deleted_at, null: true
    end

    add_index :loyalty_programs, :name, unique: true, where: "deleted_at IS NULL"

    create_table :loyalty_programs_users do |t|
      t.references :loyalty_program, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true
      t.datetime :expires_at, null: true
      t.references :payment, index: true, foreign_key: true
      t.timestamps
    end

    Translation.create(
      locale: 'en',
      key: 'aside.loyalty_program_description_html',
      value: 'loyalty program: %{name}, expires: %{expires_time}',
      interpolations: %w[name expires_time contract]
    )
  end
end
