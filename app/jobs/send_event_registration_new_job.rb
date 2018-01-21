class SendEventRegistrationNewJob < ApplicationJob
  queue_as :ibp_google_analytics_queue

  def perform(user_id)
  	ApiWrappers::GoogleAnalytics.new(User.find(user_id)).send_event_registration_new(category: 'registration', action: 'new')
  end
end