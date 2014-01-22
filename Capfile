require 'capistrano/setup'
require 'capistrano/deploy'
require 'capistrano/chruby'
require 'capistrano/bundler'
require 'capistrano/rails/assets'

set :chruby_ruby '2.1.0'

# Loads custom tasks from `lib/capistrano/tasks' if you have any defined.
Dir.glob('lib/capistrano/tasks/*.cap').each { |r| import r }
