class API::V1::Entities::Invoice < Grape::Entity
  expose :pdf_url, documentation: { type: 'String' }
end
