class RemoveActivationUser < ActiveRecord::Migration[5.1]
  def change
  	rename_column :users, :activation_code, :activation_code_OBSOLETE
  	rename_column :users, :activated_at, :activated_at_OBSOLETE

  	Parameter.find_by_name('system.enable_user_activation_code')&.destroy
  end
end
