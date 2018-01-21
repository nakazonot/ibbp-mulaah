class AddIcoTokensVolume < ActiveRecord::Migration[5.1]
  def change
    Parameter.create(name: 'coin.ico_tokens_volume', description: 'Volume of ICO tokens')
  end
end
