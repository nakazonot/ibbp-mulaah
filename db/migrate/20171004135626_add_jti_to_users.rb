class AddJtiToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :jti, :string

    User.unscoped.find_each(batch_size: 200) { |user| user.update_column(:jti, SecureRandom.uuid) }

    change_column_null :users, :jti, false
    add_index :users, :jti, unique: true
  end
end
