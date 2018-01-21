class API::V1::Entities::Promotoken < API::V1::Entities::Base
  expose :id,                     documentation: { type: 'Integer' }
  expose :code,                   documentation: { type: 'String'  }
  expose :expires_at,  format_with: :api_datetime, documentation: { type: 'Datetime' }
  expose :num_total,              documentation: { type: 'Integer' }
  expose :num_used,               documentation: { type: 'Integer' }
  expose :discount_type,          documentation: { type: 'String' }
  expose :discount_amount,        documentation: { type: 'Float' }
  expose :is_aggregated_discount, documentation: { type: 'Boolean' }
  expose :comment,                documentation: { type: 'String' }
end
