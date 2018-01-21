class AddTranslationsForKycMailer < ActiveRecord::Migration[5.1]
  def change
    Translation.create(
      locale: 'en',
      key: 'message.created_icos_id_account_notification_html',
      value: '<p>We just created ICOS ID account for you! http://icosid.com</p>',
      interpolations: %w[]
    )
    Translation.create(
      locale: 'en',
      key: 'message.created_icos_id_account_notification_subject',
      value: 'We just created ICOS ID account for you!',
      interpolations: %w[]
    )
  end
end
