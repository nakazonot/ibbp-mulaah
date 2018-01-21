class AddTranslationsForLiveChatJs < ActiveRecord::Migration[5.1]
  def change
    Translation.create(
      locale: 'en',
      key: 'live_chat_html',
      value: '',
      interpolations: %w[]
    )
  end
end
