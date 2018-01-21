ROOT_DIR = __dir__+'/../'

timeout ENV.fetch("UNICORN_TIMEOUT", 60).to_i

if !ENV['LOCAL'].nil?
  # Local mode
  worker_processes 4
  listen 3000
else
  # Production mode
  worker_processes ENV.fetch("UNICORN_WORKERS", 4).to_i
  preload_app true

  before_fork do |server, worker|
    Signal.trap 'TERM' do
      puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
      Process.kill 'QUIT', Process.pid
    end

    defined?(ActiveRecord::Base) and
      ActiveRecord::Base.connection.disconnect!
  end

  after_fork do |server, worker|
    Signal.trap 'TERM' do
      puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT'
    end

    defined?(ActiveRecord::Base) and
      ActiveRecord::Base.establish_connection
  end
end