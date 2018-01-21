class AddProfileKycTranslation < ActiveRecord::Migration[5.1]
  def change
  	Translation.create(
      locale: 'en',
      key: 'profile.kyc.widgets_html',
      value: '',
      interpolations: nil
    )
  end
end
