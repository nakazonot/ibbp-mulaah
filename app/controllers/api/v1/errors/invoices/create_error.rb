class API::V1::Errors::Invoices::CreateError < API::V1::Errors::BaseException
  def initialize(message = I18n.t('errors.messages.invoice_creation'))
    super(message: message, status: 422, code: API::V1::Errors::Types::INVOICE_CREATE_ERROR)
  end
end
