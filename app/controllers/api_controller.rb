class ApiController < ApplicationController
  include TimeConcern

  def ico_main_info
    system_info = Services::SystemInfo::SystemInfo.new(params)
    result = system_info.call

    headers['Access-Control-Allow-Origin'] = '*'

    if system_info.error == Services::SystemInfo::SystemInfo::ERROR_NOT_AUTHORIZED
      return ajax_error({error: system_info.error})
    elsif system_info.error == Services::SystemInfo::SystemInfo::ERROR_ICO_CLOSED
      return ajax_error({error: system_info.error, ico_stages: system_info.ico_stages})
    end

    ajax_ok(result)
  end

  def ico_raised
    params[:starting_at] = params[:from] if params[:from].present?
    params[:ending_at]   = params[:to] if params[:to].present?
    raised_info_service  = Services::SystemInfo::Raised.new(params)
    raised_info          = raised_info_service.call

    headers['Access-Control-Allow-Origin'] = '*'

    if raised_info_service.error == Services::SystemInfo::Raised::ERROR_NOT_AUTHORIZED
      return ajax_error({error: system_info.error})
    elsif raised_info_service.error == Services::SystemInfo::Raised::ERROR_INVALID_STARTING_AT_FORMAT
      return ajax_error({ error: 'Invalid DateTime. Required ISO 8601.' })
    elsif raised_info_service.error == Services::SystemInfo::Raised::ERROR_INVALID_ENDING_AT_FORMAT
      return ajax_error({ error: 'Invalid DateTime. Required ISO 8601.' })
    end

    ajax_ok(raised_info)
  end
end
