class InvoicedNotificationsController < ApplicationController
  include Concerns::Log::Logger

  protect_from_forgery :except => [:create]

  def create
    event = ApiWrappers::Invoiced.new.get_event(params['id'])
    return render body: nil if event.blank?

    log_info("Invoiced notification params: #{params.to_json}")
    if event.type == 'invoice.paid'
      log_info("Invoiced notification Event #{event.id} is valid")
      Services::Coin::InvoicedCreator.new(event).call
    end
    render body: nil
  rescue => e
    log_error({ message: e.message, backtrace: e.backtrace })
    render body: nil, status: 500
  end

end