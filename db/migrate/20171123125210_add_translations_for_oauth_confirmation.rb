class AddTranslationsForOauthConfirmation < ActiveRecord::Migration[5.1]
  def change
    Translation.create(
      locale: 'en',
      key: 'message.confirmation_oauth_email_instructions_html',
      value: '<p>Welcome %{email}!</p><p>You can confirm your account email through the link below:</p><p><a href="%{confirmation_url}">Confirm my account</a></p>',
      interpolations: %w[email confirmation_url]
    )
  end
end
