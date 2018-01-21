class AddMailerLayoutToTranslations < ActiveRecord::Migration[5.1]
  def change
    Translation.create(
      locale: 'en',
      key: 'message.mailer_layout',
      value: "%CONTENT".html_safe,
      interpolations: %w[content]
    )
  end
end
