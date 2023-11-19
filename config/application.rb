require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Tmp
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    config.generators do |g|
      g.template_engine :haml
    end

    # view component path for the generator
    config.view_component.view_component.path = 'app/views/components'
    # generate view component templates in a sub directory (eg, user_component/user_component.html.haml)
    config.view_component.generate.sidecar = true

    # config.eager_load_paths << Rails.root.join("extras")
    config.autoload_lib(ignore: %w[assets tasks])
    config.eager_paths << Rails.root.join("app", "views", "components")
  end
end
