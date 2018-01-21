class ContactToContract < ActiveRecord::Migration[5.1]
  def change
  	Parameter.find_by_name('links.token_contact').update_columns(name: 'links.token_contract')
  end
end
