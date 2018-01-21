class AddTranslationsForTextAfterLogo < ActiveRecord::Migration[5.1]
  def change
    Translation.create(
      locale: 'en',
      key: 'header.after_logo',
      value: '',
      interpolations: %w[]
    )
  end
end
