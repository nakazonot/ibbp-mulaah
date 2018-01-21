class AddSupportRole < ActiveRecord::Migration[5.1]
  disable_ddl_transaction!

  def change
    execute <<-SQL
      ALTER TYPE user_role_type ADD VALUE 'support';
    SQL
  end
end
