source 'http://rubygems.org'
source 'https://rails-assets.org'

ruby '2.1.0'

gem 'rails', '~> 4.1.5'
gem 'mongo', '~> 1.10'
gem 'bson_ext', '~> 1.10'
gem 'mongo_mapper', git: 'git://github.com/mongomapper/mongomapper.git', tag: 'v0.13.0.beta2'
gem 'bcrypt-ruby', '~> 3.1.5'
gem 'omniauth-twitter', '~> 1.0'
gem 'omniauth-facebook', '~> 1.6'
gem 'draper', '~> 1.3'
gem 'turbolinks', '~> 2.2'

# Assets
gem 'jquery-rails', '~> 3.1.0'
gem 'sass-rails', '~> 4.0.3'
gem 'coffee-rails', '~> 4.0.1'
gem 'uglifier', '~> 2.5'
gem 'rails-assets-selectize', '~> 0.9'
gem 'rails-assets-sifter', '~> 0.3'
gem 'rails-assets-microplugin', '~> 0.0.3'

group :test do
  gem 'turn', :require => false
  gem 'capybara', '~> 2.1'
  gem 'factory_girl_rails', '~> 4.3'
  gem 'database_cleaner', '~> 1.2'
end

group :development do
  gem 'meta_request'
  gem 'sshkit', '~> 1.3'
  gem 'capistrano', '~> 3.0'
  gem 'capistrano-rails'
  gem 'capistrano-bundler'
  gem 'capistrano-chruby', github: 'davekaro/chruby'
end
