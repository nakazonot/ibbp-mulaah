class API::V1::Entities::OTPSecret < Grape::Entity
  expose :label,   documentation: { type: 'String' }
  expose :uri,     documentation: { type: 'String' }
  expose :secret,  documentation: { type: 'String' }
end
