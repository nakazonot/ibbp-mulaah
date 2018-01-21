class AddRegistrationAgreementToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :registration_agreement, :boolean, default: false

    User.unscoped.find_each(batch_size: 200) do |user|
      user.update(registration_agreement: true)
    end
  end
end
