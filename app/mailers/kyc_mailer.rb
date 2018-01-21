class KycMailer < ApplicationMailer
  include ActionMailer::Text

  def message_created_icos_id_account_notification(email)
    mail(subject: t('message.created_icos_id_account_notification_subject'), to: email)
  end
end
