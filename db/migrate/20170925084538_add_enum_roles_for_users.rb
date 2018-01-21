class AddEnumRolesForUsers < ActiveRecord::Migration[5.1]
  def change
    execute <<-SQL
      CREATE TYPE user_role_type AS ENUM ('user', 'admin', 'admin_read_only');
    SQL

    execute <<-SQL
      ALTER TABLE users
        ALTER COLUMN role TYPE user_role_type using role::user_role_type;
    SQL
  end
end
