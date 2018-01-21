class AddSupportEmailToParameters < ActiveRecord::Migration[5.1]
  def change
    Parameter.create(name: 'links.support_email', description: 'Support email')
  end
end
