require_relative "boot"
require "rails/all"
require "devise"
require "rolify"
require "stripe"
require "cancancan"
require "kaminari"

module MrWetTest
  class Application < Rails::Application
    config.load_defaults 8.0
    
    # Configure asset pipeline
    config.asset_pipeline = :propshaft
    
    # Configure middleware
    config.middleware.use Warden::Manager
    
    config.autoload_lib(ignore: %w[assets tasks])
  end
end