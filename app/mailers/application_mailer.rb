class ApplicationMailer < ActionMailer::Base
  include ActionMailer::Text
  default from: ENV['MAILER_FROM']
  layout 'mailer'
end
