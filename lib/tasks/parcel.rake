# namespace :parcel do
#   desc "Build bundle with parcel"
#   task :build => :clobber do
#     unless system "yarn install && yarn parcel:build"
#       raise "Task parcel:build failed. Ensure yarn is installed and `yarn parcel:build` runs without errors"
#     end
#   end

#   desc "Remove parcel build"
#   task :clobber do
#     unless system "yarn install && yarn parcel:clobber"
#       raise "Task parcel:clobber failed. Ensure yarn is installed and `yarn parcel:clobber` runs without errors"
#     end
#   end
# end


# Rake::Task["assets:precompile"].enhance(["parcel:build"])

# if Rake::Task.task_defined?("test:prepare")
#   Rake::Task["test:prepare"].enhance(["parcel:build"])
# elsif Rake::Task.task_defined?("db:test:prepare")
#   Rake::Task["db:test:prepare"].enhance(["parcel:build"])
# end
