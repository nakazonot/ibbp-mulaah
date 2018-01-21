require_dependency 'api/v1/validators/currency_code'

module API::V1::Helpers::Contracts
  extend Grape::API::Helpers

  params :generate_contract do
    requires :currency,             type: String,  desc: 'Currency (code)', currency_code: true
    requires :coin_amount,          type: Float,   desc: 'Amount of tokens'
    requires :coin_price,           type: Float,   desc: 'Coin price'
    requires :buy_from_all_balance, type: Boolean, desc: 'Buy from all balance'
  end

  params :accept_contract do
    requires :id,              type: Integer, desc: 'Contract ID.'
  end
end
