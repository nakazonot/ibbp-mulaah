class SendCpaPostbackJob < ApplicationJob
  queue_as :ibb_cpa_postbacks

  def perform(postback_action, user_id, params = {})
    Services::CpaPostback::Send.new(postback_action, user_id, params).call
  end
end
