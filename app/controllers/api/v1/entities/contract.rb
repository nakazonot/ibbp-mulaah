class API::V1::Entities::Contract < Grape::Entity
  expose :id,          documentation: { type: 'Integer' }
  expose :user_id,     documentation: { type: 'Integer' }
  expose :uuid,        documentation: { type: 'Integer' }
  expose :currency,    documentation: { type: 'String' } do |contract|
    contract.info['currency']
  end
  expose :coin_amount, documentation: { type: 'Float' } do |contract|
    coin_floor(contract.info['coin_amount'])
  end
  expose :coin_amount_bonus, documentation: { type: 'Float' } do |contract|
    coin_floor(CoinBuyFormatter.new(contract, nil).calc_bonus_total)
  end
  expose :coin_amount_total, documentation: { type: 'Float' } do |contract|
    coin_amount       = coin_floor(contract.info['coin_amount'])
    coin_bonus_amount = coin_floor(CoinBuyFormatter.new(contract, nil).calc_bonus_total)

    coin_floor(coin_amount + coin_bonus_amount)
  end
  expose :coin_price,  documentation: { type: 'Float' } do |contract|
    currency_floor(contract.info['coin_price'], contract.info['currency'])
  end
  expose :coin_rate,   documentation: { type: 'Float' } do |contract|
    contract.info['coin_rate']
  end
  expose :purchase_agreement_uri, documentation: { type: 'String' } do |contract|
    Rails.application.routes.url_helpers.contract_agreement_url(contract.uuid, format: :pdf)
  end
end
