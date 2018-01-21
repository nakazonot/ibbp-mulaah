class AddWelcomeEmailToTranslations < ActiveRecord::Migration[5.1]
  def change
    Translation.create(locale: 'en', key: 'message.welcome_email_html',  interpolations: %w[email name platform_link])
    Translation.create(locale: 'en', key: 'message.welcome_email_subject')
  end
end
