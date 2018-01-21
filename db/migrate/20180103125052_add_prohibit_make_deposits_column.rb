class AddProhibitMakeDepositsColumn < ActiveRecord::Migration[5.1]
  def change
    add_column :ico_stages, :prohibit_make_deposits, :boolean, default: false
  end
end
