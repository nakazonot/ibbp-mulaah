class PaymentNotificationsController < ApplicationController
  include Concerns::Log::Logger

  protect_from_forgery :except => [:create]

  def create
    log_info("Payment notification params: #{params.to_json}, hmac: '#{request.headers['HTTP_HMAC']}'")
    merchant_id = ENV['COIN_PAYMENTS_MERCHANT_ID']

    if request.headers['HTTP_HMAC'].present? && params[:merchant].present? && params[:merchant] == merchant_id
      if notification_valid? && params['ipn_type'] == 'deposit'
        log_info("Payment notification #{params['ipn_id']} is valid")
        Services::PaymentSystem::CoinPaymentsCreator.new(params).call
      end
    end
    render body: nil
  rescue => e
    log_error({ message: e.message, backtrace: e.backtrace })
    Rollbar.error(e)
    render body: nil
  end

  private

  def notification_valid?
    secret = ENV['COIN_PAYMENTS_IPN_SECRET']
    hmac = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha512'), secret, request.raw_post)
    check_result = (request.headers['HTTP_HMAC'] == hmac)
    fail "CoinPayments: Invalid IPN Notification request: #{request.headers['HTTP_HMAC']}, expected: #{hmac}" unless check_result
    check_result
  end

end