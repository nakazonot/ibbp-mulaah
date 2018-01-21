class IcosIdKycNotificationsController < ApplicationController
  include Concerns::Log::Logger

  protect_from_forgery :except => [:create]

  def create
    log_info("Icosid notification params: #{params.to_json}")
    log_info("Icosid notification Signature: #{request.headers['X-Signature']}")

    if request.headers['X-Signature'].present?
      if notification_valid?
        log_info("Icosid notification is valid")
        Services::IcosId::KycVerificationNotify.new(params).call
      end
    end
    render body: nil
  rescue => e
    log_error({ message: e.message, backtrace: e.backtrace })
    render body: nil
  end

  private

  def notification_valid?
    secret = ENV['ICOS_ID_IPN_SECRET']

    hmac = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), secret, request.raw_post)
    enc = [[hmac].pack("H*")].pack("m0")
    enc == request.headers['X-Signature']
  end
end