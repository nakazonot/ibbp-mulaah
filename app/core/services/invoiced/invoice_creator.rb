class Services::Invoiced::InvoiceCreator
  include Concerns::Log::Logger

  def initialize(invoice_attrs, user)
    @invoice_attrs = invoice_attrs
    @user          = user
    @api_invoiced  = ApiWrappers::Invoiced.new
  end

  def call 
    find_of_create_invoice_customer
    create_invoice
  rescue Services::Invoiced::InvoiceError => e
    log_error("user: #{@user.id}. #{e.message}")
    nil
  end

  private

  def find_of_create_invoice_customer
    @invoice_customer = InvoiceCustomer.find_by(user_id: @user.id)

    if @invoice_customer.blank?
      api_customer_result = @api_invoiced.create_customer(
        name:         @invoice_attrs[:full_name],
        email:        @user.email,
        number:       @user.id.to_s,
        phone:        @invoice_attrs[:phone],
        type:         'person',
        address1:     @invoice_attrs[:address],
        city:         @invoice_attrs[:city],
        state:        @invoice_attrs[:state],
        postal_code:  @invoice_attrs[:postal_code],
        country:      @invoice_attrs[:country]
      )

      raise Services::Invoiced::InvoiceError.new('Can not create customer') if api_customer_result.blank?

      @invoice_customer = InvoiceCustomer.new(
        user_id: @user.id,
        external_id: api_customer_result.id,
        number: api_customer_result.number
      )
    else
      api_customer_result = @api_invoiced.update_customer(
        @invoice_customer.external_id,
        {
          name:         @invoice_attrs[:full_name],
          phone:        @invoice_attrs[:phone],
          address1:     @invoice_attrs[:address],
          city:         @invoice_attrs[:city],
          state:        @invoice_attrs[:state],
          postal_code:  @invoice_attrs[:postal_code],
          country:      @invoice_attrs[:country]
        }
      )
      raise Services::Invoiced::InvoiceError.new('Can not update customer') unless api_customer_result
    end

    @invoice_customer.assign_attributes(@invoice_attrs.except(:email, :amount))
    @invoice_customer.save!(validate: false)

    @invoice_customer
  end

  def create_invoice
    api_invoice_result = @api_invoiced.create_invoice(
      customer_id: @invoice_customer.external_id,
      description: ENV['INVOICED_INVOICE_DESCRIPTION'].to_s.sub('{{user_email}}', @user.email),
      amount: @invoice_attrs[:amount]
    )

    raise Services::Invoiced::InvoiceError.new('Can not create invoice') if api_invoice_result.blank?

    invoice = Invoice.new(
      invoice_customer_id: @invoice_customer.id,
      amount:              @invoice_attrs[:amount],
      external_id:         api_invoice_result.id,
      number:              api_invoice_result.number,
      payment_terms:       api_invoice_result.payment_terms,
      due_at:              Time.at(api_invoice_result.due_date),
      pdf_url:             api_invoice_result.pdf_url
    )

    invoice.save(validate: false)

    api_invoice_result.send

    log_info("User ##{@user.id} has successfully generated invoice ##{invoice.id}")

    invoice
  end
end
