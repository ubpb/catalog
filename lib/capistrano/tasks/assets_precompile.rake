# Override the deploy:assets:precompile task from capistrano/rails/assets
# with a version that uses assets:precompile locally and copies the
# precompiled files via rsync. This has two adavantages: running
# assets:precompile locally is much faster. It also fixes a strange
# bug, where the original version doesn't generates all files on the
# server.
namespace :load do
  task :defaults do
    set :rsync_cmd,   "rsync -avh"
    set :assets_role, "web"
  end
end

Rake::Task["deploy:assets:precompile"].clear_actions
namespace :deploy do
  namespace :assets do
    task :precompile do
      on roles(fetch(:assets_role)), in: :parallel do |server|
        run_locally do
          with rails_env: fetch(:rails_env), rails_groups: fetch(:rails_assets_groups) do
            # Cleanup existing assets
            execute :rake, "assets:clobber"

            # Precompile assets. That will also trigger css:build and javascript:build
            execute :rake, "assets:precompile"

            # Copy via rsync
            remote_shell = %(-e "ssh -p #{server.port}") if server.port
            rsync_cmd = "#{fetch(:rsync_cmd)} #{remote_shell} ./public/assets/ #{server.user}@#{server.hostname}:#{release_path}/public/assets/"
            if dry_run?
              SSHKit.config.output.info(rsync_cmd)
            else
              execute rsync_cmd
            end

            # Cleanup generated assets
            execute :rake, "assets:clobber"
          end
        end
      end
    end
  end
end
