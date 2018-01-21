class FreePaymentAddressGenerateJob < ApplicationJob
  queue_as :ibp_payment_address_queue

  def perform(currency = nil)
    Services::PaymentAddress::FreePaymentAddressGenerator.new(currency).call
  end
end