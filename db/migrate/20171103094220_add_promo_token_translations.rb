class AddPromoTokenTranslations < ActiveRecord::Migration[5.1]
  def change
  	Translation.create(
      locale: 'en',
      key: 'aside.promo_token_balance_title',
      value: "Promo Token balance",
      interpolations: nil
    )
    Translation.create(
      locale: 'en',
      key: 'payment_address.deposit.can_not_get_address',
      value: 'Can not get payment address. Please try again',
      interpolations: nil
    )
    Translation.create(
      locale: 'en',
      key: 'payment_address.promo_tokens.can_not_get_address',
      value: 'Can not get promo token address. Please try again',
      interpolations: nil
    )
    Translation.create(
      locale: 'en',
      key: 'promocode.promotoken.not_enabled',
      value: 'The ability to work with promo tokens is not activated',
      interpolations: nil
    )
    Translation.create(
      locale: 'en',
      key: 'promocode.promotoken.not_enough_promo_tokens',
      value: 'Not enough number of Promo Tokens',
      interpolations: nil
    )
    Translation.create(
      locale: 'en',
      key: 'message.promo_token_transaction_notification_subject',
      value: 'Your payment by promo tokens was successful!',
      interpolations: nil
    )
    Translation.create(
      locale: 'en',
      key: 'message.promo_token_transaction_notification_html',
      value: '<p>
        Thank you for your payment by promo tokens. You have successfully deposited %{amount} promo tokens to your account at <a href="%{platform_link}">%{platform_link}</a>.
      </p> <p>
        <h3 style="margin-bottom: 5px">Payment details:</h3>
        <b>Transaction ID</b>: %{transaction_id}<br/>
        <b>Account</b>: %{email}<br/>
        <b>Payment system</b>: %{payment_system}<br/>
        <b>Amount</b>: %{amount}<br/>
        <b>Contract</b>: %{contract}<br/>
        <b>Currency</b>: %{currency}<br/>
        <b>Date</b>: %{transaction_date}<br/>
      </p>',
      interpolations: %w[amount platform_link transaction_id email payment_system contract currency transaction_date]
    )

  end
end