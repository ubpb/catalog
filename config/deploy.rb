lock "~> 3.11"

set :application, "catalog"
set :repo_url, "git@github.com:ubpb/catalog.git"
set :branch, "master"
set :log_level, :debug

append :linked_files, "config/database.yml", "config/master.key", "config/ils.yml", "config/search_engine.yml", "config/application.yml"
append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"

set :rvm_type, :user
set :rvm_ruby_version, IO.read(".ruby-version").strip

set :passenger_roles, :web

set :rails_env, "production"

set :keep_releases, 3
set :keep_assets, 3

#
# NOTE: See lib/capistrano/tasks for more local tasks
#

# Hooks
before "deploy:assets:precompile", "app:yarn:install"
before "deploy:assets:precompile", "app:parcel:build"
