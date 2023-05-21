namespace :app do
  namespace :db do
    desc "Pull db from remote server and install locally"
    task :pull do
      # Find the first server in role 'db' (all db servers read the same database)
      server = Capistrano::Configuration.env.send(:servers).find{ |s| s.roles.include?(:db) }
      raise "No server in role 'db' found" if server.nil?

      # Setup variables
      dump_file_name   = "#{fetch(:application)}-#{Time.now.strftime("%Y%m%d-%H%M%S")}.dump"
      remote_dump_file = "/tmp/#{dump_file_name}"
      local_dump_file  = "/tmp/#{dump_file_name}"

      # Dump db on remote server
      on(server) do |_|
        db_config = YAML.load(capture("cat #{shared_path}/config/database.yml"), aliases: true)[fetch(:rails_env)]

        host     = db_config["host"]
        database = db_config["database"]
        username = db_config["username"]
        password = db_config["password"]

        execute("mysqldump --column-statistics=0 -h #{host} -u #{username} -p#{password} -r #{remote_dump_file} #{database}")
      end

      # Download file
      on(server) do |_|
        download!(remote_dump_file, local_dump_file)
      end

      # Restore dump locally
      run_locally do
        db_config = YAML.load(capture(:cat, "config/database.yml"), aliases: true)["development"]

        host     = db_config["host"] || "localhost"
        database = db_config["database"]
        username = db_config["username"]
        password = db_config["password"]

        username_param = username ? "-u #{username}" : ""
        password_param = password ? "-p #{password}" : ""

        execute("mysql -h #{host} #{username_param} #{password_param} -e \"DROP DATABASE IF EXISTS #{database}\"")
        execute("mysql -h #{host} #{username_param} #{password_param} -e \"CREATE DATABASE #{database}\"")
        execute("mysql -h #{host} #{username_param} #{password_param} #{database} < #{local_dump_file}")
      end

      # Delete dump on remote server
      on(server) do |_|
        execute("rm #{remote_dump_file}")
      end

      # Delete dump locally
      run_locally do
        execute("rm #{local_dump_file}")
      end
    end
  end
end
