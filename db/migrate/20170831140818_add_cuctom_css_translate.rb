class AddCuctomCssTranslate < ActiveRecord::Migration[5.1]
  def change
    Translation.create(
      [
        { locale: 'en', key: 'custom_css' },
        { locale: 'en', key: 'custom_mailer_css' },
        { locale: 'en', key: 'custom_admin_css' },
      ]
    )
  end
end
