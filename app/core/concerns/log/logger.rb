module Concerns::Log::Logger
  extend ActiveSupport::Concern

  def log
    @logger ||= Services::Logger::Creator.new(self.class.name.split('::').last.underscore).call
  end

  def log_info(message)
    log.info("#{self.class.name}: #{message}")
  end

  def log_error(message)
    log.error("#{self.class.name}: #{message}")
  end

  def log_warn(message)
    log.warn("#{self.class.name}: #{message}")
  end

  def log_params_info(params = {}, response)
    log.info(log_params(params, response))
  end

  def log_params_error(params = {}, response)
    log.error(log_params(params, response))
  end

  def log_params_warn(params = {}, response)
    log.warn(log_params(params, response))
  end

  def log_params(params, response)
    params.merge(class_name: self.class.name, response: response).to_json
  end
end
