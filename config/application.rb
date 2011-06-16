require File.expand_path('../boot', __FILE__)

require "action_controller/railtie"
require "action_mailer/railtie"
require "active_resource/railtie"
require "rails/test_unit/railtie"

Bundler.require(:default, Rails.env) if defined?(Bundler)

module Catchlater
  class Application < Rails::Application
    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %W(#{config.root}/lib/authentication)
    
    # Plugins
    config.plugins = [ :dynamic_form ]

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Filter password from the log file.
    config.filter_parameters += [:password]
  end
end
