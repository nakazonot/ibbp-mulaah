require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module IcoboxBookbuildingPlatform
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Active Job queue
    config.active_job.queue_adapter = :sidekiq
    config.action_view.default_form_builder = 'IbbpFormBuilder'

    config.action_mailer.deliver_later_queue_name = 'ibp_mailer_queue'

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = ENV['TIMEZONE'].present? ? ENV['TIMEZONE'] : 'UTC'
    config.exceptions_app = self.routes

    config.to_prepare do
      Devise::Mailer.helper ApplicationHelper
    end

    config.middleware.use Rack::Attack
  end
end
