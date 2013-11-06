ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'database_cleaner'
require 'capybara/rails'

DatabaseCleaner.strategy = :truncation

class ActiveSupport::TestCase
  include FactoryGirl::Syntax::Methods

  def setup
    DatabaseCleaner.clean
  end
end

class ActionController::TestCase
  def setup
    @request.env['HTTPS'] = 'on'
    DatabaseCleaner.clean
  end
end

class ActionDispatch::IntegrationTest
  include Capybara::DSL

  teardown do
    Capybara.reset_sessions!
    Capybara.use_default_driver
  end
end
