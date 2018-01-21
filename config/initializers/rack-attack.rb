class Rack::Attack

  blocklist('block <ip>') do |req|
    ApiWrappers::RackAttack.new.ip_in_blocklist?(req.ip)
  end

  blocklist('allow2ban sign_in scrapers') do |req|
    Rack::Attack::Allow2Ban.filter(
    	"sign_in-#{req.ip}", 
    	:maxretry => ENV.fetch("ALLOW_TO_BAN_SIGN_IN_MAXRETRY", 10).to_i, 
    	:findtime => ENV.fetch("ALLOW_TO_BAN_SIGN_IN_FINDTIME_SECOND", 60).to_i, 
    	:bantime => ENV.fetch("ALLOW_TO_BAN_SIGN_IN_BANTIME_SECOND", 3600).to_i
    ) do
      req.path == '/users/sign_in'
    end
  end
end