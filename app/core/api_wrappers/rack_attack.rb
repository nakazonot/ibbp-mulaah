class ApiWrappers::RackAttack
  require "resolv"

  BLOCKLIST_PREF = "RackAttack::blocklist::"

  def add_ip_to_blocklist(data)
    ips = data.split(';')
    result = []
    ips.each do |ip|
      key = "#{BLOCKLIST_PREF}#{ip}"
      unless ip_valid?(ip)
        result << "IP #{ip} address is not valid"
        next
      end
      Rails.cache.write(key, 1, {expires_in: nil, raw: true})
      result << "IP #{ip} address added to blocklist"
    end
    result
  end

  def remove_ip_from_blocklist(data)
    ips = data.split(';')
    result = []
    ips.each do |ip|
      key = "#{BLOCKLIST_PREF}#{ip}"
      unless ip_valid?(ip)
        result << "IP #{ip} address is not valid" 
        next
      end
      if Rails.cache.exist?(key, raw: true)
        result << "Remove IP #{ip} address from blocklist, result: #{Rails.cache.delete(key, raw: true)}"
        next
      end
      result << "IP #{ip} address not exists in blocklist"
    end
    result
  end

  def ip_in_blocklist?(ip)
    Rails.cache.exist?("#{BLOCKLIST_PREF}#{ip}", raw: true)
  end

  private

  def ip_valid?(ip)
    ip =~ Resolv::IPv4::Regex ? true : false
  end

end