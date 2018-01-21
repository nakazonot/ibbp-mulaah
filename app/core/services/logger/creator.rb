class Services::Logger::Creator
  def initialize(log_name)
    @log_name = log_name
  end

  def call
    create_logger
  end

  private

  def create_logger
    return Logger.new(STDOUT) unless ENV['LOG_TO_FILE'].to_b

    log_path = "#{Rails.root}/log/#{@log_name}.log"

    if ENV['LOG_DNA_API_KEY'].present?
      log_dna_host = ENV['ROUTES_HOST'].include?('localhost') ? 'localhost' : URI.parse(ENV['ROUTES_HOST']).host
      return LogDNA::RailsLogger.new(ENV['LOG_DNA_API_KEY'], log_dna_host, {
        logdev: log_path,
        default_app: ENV['LOG_DNA_APP_NAME']
      })
    end

    Logger.new(log_path)
  end
end
