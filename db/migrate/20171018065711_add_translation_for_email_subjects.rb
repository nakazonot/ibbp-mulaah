class AddTranslationForEmailSubjects < ActiveRecord::Migration[5.1]
  def change
    Translation.create(
      locale: 'en',
      key: 'message.payment_notification_subject',
      value: 'Your payment was successful!',
      interpolations: nil
    )
    Translation.create(
      locale: 'en',
      key: 'message.coin_payment_notification_subject',
      value: 'Your token purchase was successful!',
      interpolations: nil
    )
    Translation.create(
      locale: 'en',
      key: 'message.invoice_paid_notification_subject',
      value: "Your invoice %{invoice_number} was successfully paid!",
      interpolations: %w[invoice_number]
    )

    Translation.create(
      locale: 'en',
      key: 'devise.mailer.confirmation_instructions.subject',
      value: "Confirmation instructions",
      interpolations: nil
    )
    Translation.create(
      locale: 'en',
      key: 'devise.mailer.reset_password_instructions.subject',
      value: "Reset password instructions",
      interpolations: nil
    )
    Translation.create(
      locale: 'en',
      key: 'devise.mailer.reset_password_instructions_register_from_admin.subject',
      value: "An Account Has Been Created",
      interpolations: nil
    )
    Translation.create(
      locale: 'en',
      key: 'devise.mailer.unlock_instructions.subject',
      value: "Unlock instructions",
      interpolations: nil
    )
  end
end
