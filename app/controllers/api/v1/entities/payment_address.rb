class API::V1::Entities::PaymentAddress < Grape::Entity
  expose :payment_address,  documentation: { type: 'Integer' }
  expose :pub_key,          documentation: { type: 'String'  } do |address|
    address.pubkey
  end
  expose :dest_tag,         documentation: { type: 'String'  }
end
