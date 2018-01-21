class AddUserParametersTable < ActiveRecord::Migration[5.1]
  def change
    create_table :user_parameters do |t|
      t.references :user, index: true, foreign_key: true
      t.references :parameter, index: true, foreign_key: true
      t.string :value
      t.timestamps
    end
    add_index  :user_parameters, [:user_id, :parameter_id], unique: true

    add_column :payments, :bonus_percent, :float, null: true

    add_column :parameters, :can_overloaded, :boolean, null: false, default: false

    Parameter.find_by(name: 'user.referral_bonus_percent').update(can_overloaded: true)
    Parameter.find_by(name: 'user.referral_user_bonus_percent').update(can_overloaded: true)
  end
end
