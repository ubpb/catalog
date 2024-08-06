namespace :app do
  namespace :yarn do

    desc "Install yarn"
    task :install do
      on roles(:app, :web), in: :parallel do |host|
        within release_path do
          execute("cd #{release_path} && #{fetch(:rvm_path)}/bin/rvm #{fetch(:rvm_ruby_version)} do ./bin/yarn install")
        end
      end
    end

  end
end
