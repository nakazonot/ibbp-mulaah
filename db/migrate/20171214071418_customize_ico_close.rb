class CustomizeIcoClose < ActiveRecord::Migration[5.1]
  def change
    Translation.create([
      {
      	locale: 'en',
        key: 'main.close_ico.title',
        value: 'The %{coin_name} fundraiser is closed.',
        interpolations: %w[coin_name]
      },
      {
      	locale: 'en',
        key: 'main.close_ico.aside.currency_raised',
        value: '%{currency} raised',
        interpolations: %w[currency]
      }
    ])
  end
end
