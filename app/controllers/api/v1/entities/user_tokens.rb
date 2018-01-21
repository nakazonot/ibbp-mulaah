class API::V1::Entities::UserTokens < Grape::Entity
  expose :coin_count,                   documentation: { type: 'Float' } do |tokens|
    coin_floor(tokens[:coin_count])
  end
  expose :referral_coin_count,          documentation: { type: 'Float' } do |tokens|
    coin_floor(tokens[:referral_coin_count])
  end
end
