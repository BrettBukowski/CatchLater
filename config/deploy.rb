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
    on roles(:app) do
      upload! "config/initializers/omniauth.rb", "#{deploy_to}/current/config/initializers/omniauth.rb"
      upload! "config/initializers/secret_token.rb", "#{deploy_to}/current/config/initializers/secret_token.rb"
    end
  end

  desc "Upload built snack+qwery code"
  task :upload_core_js do
    on roles(:app) do
      path = "vendor/assets/javascripts/externals/snack/builds"

      within release_path do
        execute :mkdir, "-p #{path}"
      end

      upload! "#{path}/snack-qwery.js", "#{deploy_to}/current/#{path}/snack-qwery.js"
    end
  end

  desc "Build static assets"
  task :build_statics do
    on roles(:app) do
      within release_path do
        execute :bundle, "exec rake RAILS_ENV=production assets:bookmarklet"
        execute :bundle, "exec rake RAILS_ENV=production assets:static_pages"
      end
    end
  end

  after :publishing, "deploy:upload_config_files"
  after :publishing, "deploy:upload_core_js"
  after :publishing, "deploy:build_statics"
  after :finishing, "deploy:restart"
  after :finishing, "deploy:cleanup"
end
