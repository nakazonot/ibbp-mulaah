class AddTranslationForTimer < ActiveRecord::Migration[5.1]
  def change
    Translation.create(
      locale: 'en',
      key: 'aside.timer_title',
      value: '%{ico_stage_name} TIMER',
      interpolations: %w[ico_stage_name]
    )
  end
end
