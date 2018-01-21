class AddTranslationsDeviseMail < ActiveRecord::Migration[5.1]
  def change
    Translation.create(
      locale: 'en',
      key: 'message.reset_password_instructions_html',
      value: '<p>Hello %{email}!</p><p>Someone has requested a link to change your password. You can do this through the link below.</p><p><a href="%{reset_password_url}">Change my password</a></p><p>If you didn\'t request this, please ignore this email.</p><p>Your password won\'t change until you access the link above and create a new one.</p>',
      interpolations: %w[email reset_password_url]
    )
    Translation.create(
      locale: 'en',
      key: 'message.reset_password_instructions_register_from_admin_html',
      value: '<p>ICO %{coin_name} account created.</p><p>An account has been created for you at <a href="%{root_url}">%{root_url}</a>. Please, set your password and use it along with your E-Mail address to sign into <a href="%{root_url}">%{root_url}</a>.</p><p><a href="%{edit_password_url}">Set my password</a></p>',
      interpolations: %w[coin_name root_url edit_password_url coin_tiker]
    )
    Translation.create(
      locale: 'en',
      key: 'message.unlock_instructions_html',
      value: '<p>Hello %{email}!</p><p>Your account has been locked due to an excessive number of unsuccessful sign in attempts.</p><p>Click the link below to unlock your account:</p><p><a href="%{unlock_url}">Unlock my account</a></p>',
      interpolations: %w[email unlock_url]
    )
  end
end
