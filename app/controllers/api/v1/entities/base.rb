class API::V1::Entities::Base < Grape::Entity
  format_with(:api_datetime) do |datetime|
    datetime.present? ? datetime.in_time_zone.to_formatted_s(:api_datetime) : datetime
  end

  format_with(:api_date) do |date|
    date.present? ? date.to_formatted_s(:api_date) : date
  end
end
