class Services::SystemInfo::SystemInfo
  ERROR_NOT_AUTHORIZED = 'authorization_failed'.freeze
  ERROR_ICO_CLOSED     = 'ico_closed'.freeze

  attr_reader :error, :ico_stages

  def initialize(params)
    @params = params.deep_dup
    @config_parameters = Parameter.get_all
    @authorization_key = @config_parameters['system.authorization_key']
  end

  def call
    return check_errors if check_errors.present?
    current_stage = IcoStage.stage_by_date(Time.current)
    IcoMainInfoFormatter.new(@ico_stages, current_stage, @config_parameters).view_data
  rescue Services::SystemInfo::SystemInfoError => e
    @error = e.message
    nil
  end

  private

  def check_errors
    if @authorization_key.present? && @authorization_key != @params[:authorization_key]
      raise Services::SystemInfo::SystemInfoError, ERROR_NOT_AUTHORIZED
    end
    @ico_stages = IcoStage.order(:date_start)
    unless Parameter.ico_enabled
      raise Services::SystemInfo::SystemInfoError, ERROR_ICO_CLOSED
    end
  end
end