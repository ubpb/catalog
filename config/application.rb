require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# Enable debuggging via rdbg in "attach" mode.
if defined?(Rails::Server) && Rails.env.development? && ENV["DEBUG_MODE"] == "attach"
  require "debug/open_nonstop"
end

module Catalog
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    config.time_zone = "Berlin"

    # Setup the host to make full URLs work for the mailer.
    routes.default_url_options = {
      host: ENV["KATALOG_HOST"] || "localhost:3000"
    }

    # Bypass internal error logic.
    # Errors are matched via routes to the corrosponing errors#type in the ErrorsController.
    config.exceptions_app = self.routes
  end
end
