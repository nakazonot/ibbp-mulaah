class AddActivationCodeToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :activation_code, :string
    add_index  :users, [:activation_code], unique: true

    add_column    :users, :activated_at, :datetime

    Parameter.create(
      [
        { name: 'system.enable_user_activation_code', value: '0', description: 'Включить активацию аккаунта по ссылке, предоставленной модератором (включить=1, выключить=0)'}
      ]
    )

    # generate activation info for existing users
    User.unscoped.find_each(batch_size: 200) do |user|
      user.update(activation_code: SecureRandom.hex(12), activated_at: user.created_at)
    end

  end
end
