class AddCustomJsTranslate < ActiveRecord::Migration[5.1]
  def change
    Translation.create( locale: 'en', key: 'custom_js' )
  end
end
