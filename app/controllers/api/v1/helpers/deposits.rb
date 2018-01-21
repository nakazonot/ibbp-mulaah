require_dependency 'api/v1/validators/currency_code'

module API::V1::Helpers::Deposits
  extend Grape::API::Helpers

  params :generate_address do
    requires :currency,   type: String, desc: 'Currency (code)', currency_code: true
  end
end
