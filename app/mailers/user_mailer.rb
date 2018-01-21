class UserMailer < ApplicationMailer

  def welcome_email(user_id)
    @user = User.find_by(id: user_id)
    return if @user.nil?
    mail(subject: t('message.welcome_email_subject'), to: @user.email)
  end
end
