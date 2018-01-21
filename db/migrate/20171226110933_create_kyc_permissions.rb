class CreateKycPermissions < ActiveRecord::Migration[5.1]
  def change
  	execute <<-SQL
      CREATE TYPE kyc_permission_type AS ENUM ('make_deposit', 'token_buy', 'token_receive');
    SQL
    execute <<-SQL
      CREATE TYPE kyc_permission_country_select_type AS ENUM ('include', 'exclude');
    SQL

    create_table :kyc_permissions do |t|
      t.column :permission_type, :kyc_permission_type, null: false
      t.column :country_select_type, :kyc_permission_country_select_type, null: true
      t.text :country_list, array: true, null: true
      t.integer :age, null: true

      t.timestamps
      t.datetime :deleted_at, null: true
    end
  end
end
