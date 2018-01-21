class TestMailer < ApplicationMailer
  helper ApplicationHelper

  def test_mail(email)
    mail(subject: 'Test Mail', to: email)
  end
end