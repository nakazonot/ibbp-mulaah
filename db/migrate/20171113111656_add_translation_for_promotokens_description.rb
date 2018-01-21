class AddTranslationForPromotokensDescription < ActiveRecord::Migration[5.1]
  def change
  	Translation.create(
      	locale: 'en',
        key: 'profile.promocodes.promotokens.description_html',
        value: '<p class="text-justify">Send promotokens to address above. As soon as transaction confirmed, <b>%{promotoken_code}</b> promocode will be available in order to use the discount on promotokens.</p>',
      	interpolations: %w[promotoken_code]
    )

    translations = Translation.where(key: 'promocode.promotoken.not_enough_promo_tokens')
    translations.first.destroy if translations.count > 1
  end
end
