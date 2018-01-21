namespace :blocklist do
  desc "Added IP to blocklist. Example: rake blocklist:add[127.0.0.1] rake blocklist:add['128.0.0.1;129.0.0.1']"
  task :add, [:ip] => [:environment] do |task, args|
    raise "\nEnter ip address" if args[:ip].blank?
    ApiWrappers::RackAttack.new.add_ip_to_blocklist(args[:ip]).each do |result|
      puts result
    end
  end

  desc "Removed IP from blocklist. Example: rake blocklist:remove[127.0.0.1] rake blocklist:remove['128.0.0.1;129.0.0.1']"
  task :remove, [:ip] => [:environment] do |task, args|
    raise "\nEnter ip address" if args[:ip].blank?
    ApiWrappers::RackAttack.new.remove_ip_from_blocklist(args[:ip]).each do |result|
      puts result
    end
  end
end