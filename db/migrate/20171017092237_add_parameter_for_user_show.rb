class AddParameterForUserShow < ActiveRecord::Migration[5.1]
  def change
  	Parameter.create(name: 'user.show_identification', value: 'email', description: 'Attribute identifying the user (id/email)')
  end
end
