class AddParameterAuthKey < ActiveRecord::Migration[5.1]
  def change
    Parameter.create(
      [
        { name: 'system.authorization_key', description: 'Ключ, для получения сведений о собранных на ICO средств'},
      ]
    )
  end
end
