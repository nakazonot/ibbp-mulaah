class KycMailerPreview < ActionMailer::Preview
  def message_created_icos_id_account_notification
    KycMailer.message_created_icos_id_account_notification(User.first.email)
  end
end
