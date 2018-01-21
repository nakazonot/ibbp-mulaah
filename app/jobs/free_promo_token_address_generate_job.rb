class FreePromoTokenAddressGenerateJob < ApplicationJob
  queue_as :ibp_payment_address_queue

  def perform
    Services::PaymentAddress::FreePromoTokenAddressGenerator.new.call
  end
end