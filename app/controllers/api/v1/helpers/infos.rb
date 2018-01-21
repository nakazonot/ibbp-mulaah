require_dependency 'api/v1/validators/iso8601'

module API::V1::Helpers::Infos
  extend Grape::API::Helpers

  params :infos_system do
    optional :authorization_key, type: String,   desc: 'Authorization Key.'
  end

  params :infos_raised do
    optional :authorization_key, type: String,   desc: 'Authorization Key.'
    optional :starting_at,       type: String,   desc: 'Starting at time in ISO8601.', iso8601: true
    optional :ending_at,         type: String,   desc: 'Ending at time in ISO8601.',   iso8601: true
  end
end
