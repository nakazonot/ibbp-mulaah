class AddTranslationAgreementLabel < ActiveRecord::Migration[5.1]
  def change
  	Translation.create(
      [
        { locale: 'en', key: 'registration.agreement_label_html', value: 'I agree with <a target="_blank" href="%{link}">Terms of Services</a>' },
      ]
    )
  end
end
