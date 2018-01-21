require_dependency 'api/v1/validators/positive'

module API::V1::Helpers::Calculations
  extend Grape::API::Helpers

  params :estimates_currencies do
    requires :coin_amount, type: Float, desc: 'Coin amount', positive: true
  end

  params :estimates_tokens do
    requires :coin_price,  type: Float, desc: 'Coin price',  positive: true
  end
end
