class CreateParameters < ActiveRecord::Migration[5.1]
  def change
    create_table :parameters do |t|
      t.string    :name
      t.string    :value
      t.string    :description

      t.datetime  :updated_at, null: false
    end

    Parameter.create(
      [
        { name: 'ico.date_start', description: 'Дата начала ICO (yyyy-mm-dd)' },
        { name: 'ico.date_end', description: 'Дата окончания ICO (yyyy-mm-dd)' },
        { name: 'ico.bonus_percent', description: 'Размер бонуса на время проведения ICO' },
        { name: 'presale.date_start', description: 'Дата начала присейла (yyyy-mm-dd)' },
        { name: 'presale.date_end', description: 'Дата окончания присейла (yyyy-mm-dd)' },
        { name: 'presale.bonus_percent', description: 'Размер бонуса на время проведения присейла' },
        { name: 'user.eth_payment_address', description: 'Номер ETH кошелька, на который будет приходить оплата' },
        { name: 'links.ico_site', description: 'Ссылка для кнопки "ICO SITE"' },
        { name: 'links.white_paper', description: 'Ссылка для кнопки "WHITE PAPER"' },
        { name: 'links.token_contact', description: 'Ссылка для кнопки "TOKEN CONTACT"' },
        { name: 'links.slack', description: 'Ссылка на канал Slack' },
        { name: 'links.telegram', description: 'Ссылка на канал Telegram' },
        { name: 'links.we_chat', description: 'Ссылка на канал WeChat' },
        { name: 'coin.name', description: 'Имя валюты, для которой проводится ICO (например, ExampleCoin)' },
        { name: 'coin.tiker', description: 'Имя валюты, для которой проводится ICO (например, EXCN)' },
        { name: 'coin.to_usd_rate', description: 'Курс валюты по отношению к USD' },
        { name: 'coin.emission_volume', description: 'Объем эмиссии валюты' }
      ]
    )
  end
end
