class AddSupportEmalToOptions < ActiveRecord::Migration[5.1]
  def change
    Parameter.where(name: 'coin.emission_volume').delete_all
    Parameter.create(
      [
        { name: 'ico.support_email', description: 'Email технической поддержки'},
        { name: 'links.faq', description: 'Ссылка на FAQ'},
        { name: 'coin.investments_volume', description: 'Объем целевых инвестиций (USD)'},
      ]
    )
  end
end
