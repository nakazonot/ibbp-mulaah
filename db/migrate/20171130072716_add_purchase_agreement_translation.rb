class AddPurchaseAgreementTranslation < ActiveRecord::Migration[5.1]
  def change
  	Translation.create(
      locale: 'en',
      key: 'purchase.agreement_html',
      value: '',
      interpolations: nil
    )
  end
end
