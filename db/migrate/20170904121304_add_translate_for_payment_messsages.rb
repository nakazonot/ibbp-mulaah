class AddTranslateForPaymentMesssages < ActiveRecord::Migration[5.1]
  def change
    invoice_template = <<~HTML
      <p>
        Thank you for your payment. You have successfully deposited %{amount} %{currency} to your account at <a href="%{platform_link}">%{platform_link}</a>.
      </p>
      <p>
        <h3 style="margin-bottom: 5px">Payment details:</h3>
        <b>Invoice Number</b>: %{invoice_number}<br/>
        <b>Transaction ID</b>: %{transaction_id}<br/>
        <b>Account</b>: %{email}<br/>
        <b>Payment system</b>: %{payment_system}<br/>
        <b>Amount</b>: %{amount} %{currency}<br/>
        <b>Date</b>: %{transaction_date}<br/>
      </p>
    HTML

    coin_payment_template = <<~HTML
      <p>
        Thank you for your payment. You have successfully purchased %{coin_amount} %{coin_tiker} for %{amount} %{currency} in your account at <a href="%{platform_link}">%{platform_link}</a>.
      </p>
      <p>
        <h3 style="margin-bottom: 5px">Purchase details:</h3>
        <b>Transaction ID</b>: %{transaction_id}<br/>
        <b>Account</b>: %{email}<br/>
        <b>Coins</b>: %{coin_amount} %{coin_tiker}<br/>
        <b>Price</b>: %{price} %{currency}<br/>
        <b>Amount</b>: %{amount} %{currency}<br/>
        <b>Date</b>: %{transaction_date}<br/>
      </p>
    HTML


    Translation.create(
      locale: 'en',
      key: 'message.invoice_paid_notification_html',
      value: invoice_template.html_safe,
      interpolations: %w[amount currency platform_link invoice_number transaction_id email payment_system transaction_date]
    )

    Translation.create(
      locale: 'en',
      key: 'message.coin_payment_notification_html',
      value: coin_payment_template.html_safe,
      interpolations: %w[coin_amount platform_link transaction_id email price currency amount transaction_date coin_tiker]
    )
  end
end
