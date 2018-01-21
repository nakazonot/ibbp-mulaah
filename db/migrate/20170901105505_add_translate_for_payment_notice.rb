class AddTranslateForPaymentNotice < ActiveRecord::Migration[5.1]
  def change
    template = <<~HTML
      <p>
        Thank you for your payment. You have successfully deposited %{amount} %{currency} to your account at <a href="%{platform_link}">%{platform_link}</a>.
      </p>
      <p>
        <h3 style="margin-bottom: 5px">Payment details:</h3>
        <b>Transaction ID</b>: %{transaction_id}<br/>
        <b>Account</b>: %{email}<br/>
        <b>Payment system</b>: %{payment_system}<br/>
        <b>Amount</b>: %{amount} %{currency}<br/>
        <b>Date</b>: %{transaction_date}<br/>
      </p>
    HTML


    Translation.create(
      locale: 'en',
      key: 'message.payment_notification_html',
      value: template.html_safe
    )
  end
end
