require 'bundler/capistrano'

set :application, 'catchlater'
set :scm, 'git'
set :repository, 'git://github.com/BrettBukowski/CatchLater.git'
set :branch, "master"

server 'catchlater.com', :app, :web, :db, :primary => true

set :user, 'brett'
set :deploy_to, '/var/catchlater'
set :use_sudo, true
set :deploy_via, :copy
set :copy_strategy, :export
default_run_options[:pty] = true

# Passenger
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end

namespace :files do
  desc "Upload config files outside of git"
  task :upload_config_files do
    upload "config/initializers/omniauth.rb", "#{deploy_to}/current/config/initializers/omniauth.rb"
    upload "config/initializers/secret_token.rb", "#{deploy_to}/current/config/initializers/secret_token.rb"
  end
  
  desc "Upload built snack+qwery code"
  task :upload_core_js do
    run "cd #{deploy_to}/current/vendor/assets/javascripts/externals; mkdir -p snack/builds"
    upload "vendor/assets/javascripts/externals/snack/builds/snack-qwery.js",
    "#{deploy_to}/current/vendor/assets/javascripts/externals/snack/builds/snack-qwery.js"
  end
end

# Don't use `rake` as a namespace... https://github.com/capistrano/capistrano/pull/97
namespace :rake_tasks do
  desc "Build the bookmarklet app"
  task :build_js do
    run "cd #{deploy_to}/current; /usr/bin/env rake assets:bookmarklet"
  end
end

after "deploy:create_symlink", "files:upload_config_files", "files:upload_core_js", "rake_tasks:build_js"
after "deploy:restart", "deploy:cleanup"
