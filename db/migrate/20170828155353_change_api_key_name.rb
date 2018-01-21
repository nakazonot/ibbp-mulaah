class ChangeApiKeyName < ActiveRecord::Migration[5.1]
  def change
    Parameter.find_by(name: 'system.authorization_key').update_attribute(:description, 'API-key for obtaining the main info about ICO')
  end
end
