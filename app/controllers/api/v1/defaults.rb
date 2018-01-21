module API::V1::Defaults
  extend ActiveSupport::Concern

  def self.api_error(api, details, status, type)
    description = {
      type: type,
      details: details
    }

    log_error(api, description, status)
    api.error!({ error: description }, status)
  end

  def self.log_error(api, details, status)
    request       = Rack::Request.new(api.env)
    request_info  = {
      path:   request.path,
      method: request.request_method,
      status: status,
      ip:     request.ip,
      params: ActionDispatch::Http::ParameterFilter.new(Rails.application.config.filter_parameters).filter(request.params)
    }

    logger.error("#{details.to_json} REQUEST -- : #{request_info.inspect}")
  end

  def self.logger
    @logger ||= Services::Logger::Creator.new('api').call
  end

  included do
    helpers API::V1::Helpers::UserAbility
    helpers API::V1::Helpers::Users

    version 'v1', using: :header, vendor: :api
    format :json

    before do
      user_email_to_downcase
      authorize_user!
    end

    rescue_from API::V1::Errors::BaseException do |exception|
      API::V1::Defaults.api_error(self, exception.message, exception.status, exception.code)
    end

    rescue_from ActiveRecord::RecordNotFound do |exception|
      API::V1::Defaults.api_error(self, exception.message, 404, API::V1::Errors::Types::NOT_FOUND_ERROR)
    end

    rescue_from Grape::Exceptions::ValidationErrors do |exception|
      errors = {}
      exception.each do |attribute, error|
        errors[attribute.first] = [] unless errors[attribute.first]
        errors[attribute.first].push(error)
      end

      API::V1::Defaults.api_error(self, errors, 422, API::V1::Errors::Types::VALIDATION_ERROR)
    end

    rescue_from ActiveRecord::RecordInvalid do |exception|
      API::V1::Defaults.api_error(self, exception.record.errors, 422, API::V1::Errors::Types::VALIDATION_ERROR)
    end

    rescue_from JWT::DecodeError do |exception|
      API::V1::Defaults.api_error(self, exception.message, 401, API::V1::Errors::Types::JWT_DECODE_ERROR)
    end

    if Rails.env.production?
      rescue_from :all do |exception|
        API::V1::Defaults.logger.error("Internal server error: #{exception.message} Backtrace: #{exception.backtrace}")
        API::V1::Defaults.api_error(self, 'Internal server error', 500, API::V1::Errors::Types::SERVER_ERROR)
      end
    end
  end
end
