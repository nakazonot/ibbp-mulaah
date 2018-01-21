class Services::SystemInfo::RequestInfo
  def initialize(request)
    @request = request
  end

  def call
    return {} if @request.blank?
    pull_ip

    { ip: @ip, country: country, lang: lang }
  end

  private

  def pull_ip
    if @request.class == ActionDispatch::Request
      @ip = @request.remote_ip
    elsif @request.class == Grape::Request
      @ip = @request.ip
    end
  end

  def lang
    @request.env['HTTP_ACCEPT_LANGUAGE'].scan(/[a-z]{2}(?=;)/).first
  end

  def country
    geoip ||= GeoIP.new("#{Rails.root}/db/GeoIP.dat")
    geoip_location = geoip.country(@ip)
    if geoip_location.present? && geoip_location['country_code3'] != '--'
      return geoip_location['country_code3']
    end
    nil
  end
end
