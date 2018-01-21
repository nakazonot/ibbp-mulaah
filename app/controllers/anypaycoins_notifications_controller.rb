class AnypaycoinsNotificationsController < ApplicationController
  include Concerns::Log::Logger

  protect_from_forgery :except => [:create]

  def create
    log_info("AnyPayCoins notification params: #{params.to_json} hash: '#{params['Hash']}'")
    client_id = ENV['ANY_PAY_COINS_CLIENT_ID']

    if params['Hash'].present? && params['ClientId'].present? && params['ClientId'] == client_id
      if notification_valid? && params['Amount'].present? && params['Txid'].present?
        log_info("AnyPayCoins notification with Txid ##{params['Txid']} is valid")
        Services::PaymentSystem::AnyPayCoinsCreator.new(params).call if params['Type'] == 'receive'
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
    secret = ENV['ANY_PAY_COINS_IPN_SECRET']

    data = {
      'Address':        params['Address'],
      'Amount':         params['Amount'],
      'Args':           params['Args'],
      'ClientId':       params['ClientId'],
      'Confirmations':  params['Confirmations'],
      'Contract':       params['Contract'],
      'Currency':       params['Currency'],
      'Decimals':       params['Decimals'],
      'Details':        params['Details'],
      'Receipt':        params['Receipt'],
      'Status':         params['Status'],
      'Txid':           params['Txid'],
      'Type':           params['Type'],
    }

    hmac = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), secret, data.to_query)
    enc = [[hmac].pack("H*")].pack("m0")
    check_result = (enc == params['Hash'])
    fail "AnyPayCoins: Invalid IPN Notification request: #{params['Hash']}, expected: #{enc}" unless check_result
    check_result
  end
end