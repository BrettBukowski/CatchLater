set :application, 'catchlater'
set :repo_url, 'git@github.com:BrettBukowski/CatchLater.git'

set :user, 'brett'
set :deploy_to, '/var/catchlater'
set :scm, :git

set :format, :pretty
set :log_level, :debug
set :pty, true

set :linked_files, %w{config/mongo.yml}
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

set :keep_releases, 5

set :chruby_ruby, 'ruby-2.1.0'

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end

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

  desc "Build the bookmarklet app"
  task :build_js do
    run "cd #{deploy_to}/current; bundle exec rake RAILS_ENV=production assets:bookmarklet"
  end

  after :publishing, "deploy:upload_config_files", "deploy:upload_core_js", "deploy:build_js"
  after :finishing, "deploy:restart"
  after :finishing, 'deploy:cleanup'
end
