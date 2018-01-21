class API::V1::Entities::Translation < Grape::Entity
  expose :id,                   documentation: { type: 'Integer' }
  expose :locale,               documentation: { type: 'String'  }
  expose :key,                  documentation: { type: 'String'  }
  expose :value,                documentation: { type: 'String'  }
end
