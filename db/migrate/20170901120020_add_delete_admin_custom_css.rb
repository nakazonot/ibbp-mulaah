class AddDeleteAdminCustomCss < ActiveRecord::Migration[5.1]
  def change
  	Translation.where(key: ['custom_mailer_css', 'custom_admin_css']).destroy_all
  end
end
