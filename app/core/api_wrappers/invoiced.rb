require "invoiced"

class ApiWrappers::Invoiced
  include Concerns::Log::Logger

  def initialize
    @api_invoiced = Invoiced::Client.new(ENV['INVOICED_API_KEY'], ENV['INVOICED_TEST_MODE'].to_i == 1)
  end

  def create_customer(options)
    result = @api_invoiced.Customer.create(options)
    return result if result.present? && result.kind_of?(Invoiced::Customer)
    log_params_error(options.merge(method: 'create_customer'), result)
    nil
  rescue Invoiced::ErrorBase => e
    log_params_error(options.merge(method: 'create_customer'), result)
    nil
  end

  def update_customer(id, options)
    customer = @api_invoiced.Customer.retrieve(id)
    if customer.blank?
      log_params_error(options.merge(method: 'update_customer', id: id), 'Customer not found')
      return false
    end

    customer.name        = options[:name].present? ? options[:name] : nil
    customer.phone       = options[:phone].present? ? options[:phone] : nil
    customer.address1    = options[:address1].present? ? options[:address1] : nil
    customer.city        = options[:city].present? ? options[:city] : nil
    customer.state       = options[:state].present? ? options[:state] : nil
    customer.postal_code = options[:postal_code].present? ? options[:postal_code] : nil
    customer.country     = options[:country].present? ? options[:country] : nil
    return true if customer.save
    log_params_error(options.merge(method: 'update_customer', id: id), 'Can not update customer: API error')
    false
  rescue Invoiced::ErrorBase => e
    log_params_error(options.merge(method: 'update_customer', id: id), e.error)
    false
  end

  def create_invoice(options)
    result = @api_invoiced.Invoice.create(
      customer: options[:customer_id],
      currency: 'USD',
      payment_terms: ENV['INVOICED_PAYMENT_TERMS'],
      items: [
        {
          name: options[:description],
          quantity: 1,
          unit_cost: options[:amount],
        }
      ],
      taxes: [
        {
          amount: 0
        }
      ]
    )

    return result if result.present? && result.kind_of?(Invoiced::Invoice)
    log_params_error(options.merge(method: 'create_invoice'), result)
    nil
  rescue Invoiced::ErrorBase => e
    log_params_error(options.merge(method: 'create_invoice'), result)
    nil
  end

  def get_event(event_id)
    result = @api_invoiced.Event.retrieve(event_id)
    return result if result.present? && result.kind_of?(Invoiced::Event)
    log_params_error({method: 'get_event', event_id: event_id}, result)
    nil
  rescue Invoiced::ErrorBase => e
    log_params_error({method: 'get_event', event_id: event_id}, result)
    nil
  end

end