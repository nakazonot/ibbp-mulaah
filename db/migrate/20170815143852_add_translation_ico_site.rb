class AddTranslationIcoSite < ActiveRecord::Migration[5.1]
  def change
    Translation.create(
      [
        { locale: 'en', key: 'nav.ico_site', value: 'ICO SITE' },
      ]
    )
  end
end
