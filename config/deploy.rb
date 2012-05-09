require 'bundler/capistrano'

set :application, 'catchlater'
set :scm, 'git'
set :repository, 'git://github.com/BrettBukowski/CatchLater.git'

server 'localhost', :app, :db, :primary => true

ssh_options[:keys] = "/Users/brettbukowski/.ssh"

set :user, 'deployer'
set :group, 'deployer'
set :deploy_to, '/var/catchlater'
set :use_sudo, false
set :deploy_via, :copy
set :copy_strategy, :export

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

# Passenger
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  desc "Restart the application"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end

desc "Upload config files that aren't in git"
task :upload_config_files do
  upload "initializers/omniauth.rb", "#{deploy_to}/config/initializers/omniauth.rb"
  upload "initializers/secret_token.rb", "#{deploy_to}/config/initializers/secret_token.rb"
end