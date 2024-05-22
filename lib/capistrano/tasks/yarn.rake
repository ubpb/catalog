namespace :app do
  namespace :yarn do

    desc "Install yarn"
    task :install do
      on roles(:app, :web), in: :parallel do |host|
        within release_path do
          execute("cd #{release_path} && ./bin/yarn install")
        end
      end
    end

  end
end
