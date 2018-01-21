class AddParametersLinksLogo < ActiveRecord::Migration[5.1]
  def change
    Parameter.create(name: 'links.logo', value: '', description: 'Ссылка на логотип')
  end
end
