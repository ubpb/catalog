namespace :app do
  namespace :parcel do

    desc "Run parcel:build"
    task :build do
      on roles(:app, :web), in: :parallel do |host|
        within release_path do
          execute("cd #{release_path} && yarn parcel:build")
        end
      end
    end

  end
end
