module ApiWrappers
  module CoinPaymentsLogger
    extend ActiveSupport::Concern

    def log
      return @coin_payment_logger unless @coin_payment_logger.nil?
      return @coin_payment_logger = Logger.new(STDOUT) if ENV['LOG_TO_FILE'].to_i == 0
      log_path = "#{Rails.root}/log/coin_payments"
      FileUtils.mkdir_p Rails.public_path.join(log_path)
      @coin_payment_logger = Logger.new("#{log_path}/coin_payments-#{Time.current.strftime('%Y-%m-%d')}.log")
    end

    def log_info(params = {}, response)
      log.info(log_params(params, response))
    end

    def log_error(params = {}, response)
      log.error(log_params(params, response))
    end

    def log_warn(params = {}, response)
      log.warn(log_params(params, response))
    end

    def log_params(params, response)
      params.merge(class_name: self.class.name, response: response).to_json
    end

  end
end
