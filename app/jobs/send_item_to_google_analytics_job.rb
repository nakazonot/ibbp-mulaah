class SendItemToGoogleAnalyticsJob < ApplicationJob
  queue_as :ibp_google_analytics_queue

  def perform(contract_id)
  	contract = BuyTokensContract.find(contract_id)
  	ApiWrappers::GoogleAnalytics.new(contract.user).send_item_to_google_analytics(contract)
  end
end