namespace :app do
  namespace :maintenance do
    desc "Activate maintenance mode"
    task :on do
      on roles(:web), in: :parallel do |host|
        within release_path do
          execute :touch, "public/MAINTENANCE_ON"
        end
      end
    end

    desc "Deactivate maintenance mode"
    task :off do
      on roles(:web), in: :parallel do |host|
        within release_path do
          execute :rm, "public/MAINTENANCE_ON"
        end
      end
    end
  end
end
