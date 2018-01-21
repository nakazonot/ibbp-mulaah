class API::V1::Entities::Payment < API::V1::Entities::Base
  expose :id,                  documentation: { type: 'Integer', description: 'Payment identifier' }
  expose :status,              documentation: { type: 'String',  description: 'Status' }
  expose :amount,              documentation: { type: 'Float',   description: 'Amount' } do |payment|
    original_number_format(payment.amount_buyer)
  end
  expose :currency,            documentation: { type: 'String',  description: 'Currency' } do |payment|
    payment.currency_buyer
  end
  expose :ico_currency_amount, documentation: { type: 'Float',   description: 'Amount in ICO currency' } do |payment|
    ico_currency_number_format(payment.ico_currency_amount) unless payment.ico_currency_amount.nil?
  end
  expose :tokens,              documentation: { type: 'Float',   description: 'Tokens' } do |payment|
    payment.iso_coin_amount
  end
  expose :description,         documentation: { type: 'String',  description: 'Description' } do |payment|
    payment.description.present? ? payment.description : PaymentHistoryFormatter.descriptions[payment.payment_type]
  end
  expose :type,                documentation: { type: 'String', description: 'Payment type' } do |payment|
    payment.payment_type
  end
  expose :created_at, format_with: :api_datetime, documentation: { type: 'Datetime', description: 'Created At in ISO8601' }
  expose :contract_uri,        documentation: { type: 'String', description: 'URI to contract' } do |payment|
    if payment.buy_tokens_contract&.uuid.present? && Parameter.buy_tokens_agreement_enabled?
      Rails.application.routes.url_helpers.contract_agreement_url(payment.buy_tokens_contract.uuid, format: :pdf)
    end
  end
  expose :invoice_uri,         documentation: { type: 'String', description: 'URI to invoice' } do |payment|
    payment.invoice&.pdf_url
  end
end
