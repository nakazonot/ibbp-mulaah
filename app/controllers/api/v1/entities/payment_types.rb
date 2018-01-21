class API::V1::Entities::PaymentTypes < Grape::Entity
  expose :types,  documentation: { type: 'Hash' }
end
