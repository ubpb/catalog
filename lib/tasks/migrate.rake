require "dotenv"
Dotenv.load("migration.env")

namespace :migrate do

  desc "Migrate users"
  task :users => :environment do
    confirm(
      message: "All existing users will be deleted! Continue?",
      token: "yes"
    )

    puts "Deleting existing users..."
    User.destroy_all

    puts "Migrating users from old katalog..."
    User.transaction do
      source_db[:users].each do |user|
        print "."

        User.create!(
          id: user[:id],
          ils_primary_id: user[:ilsuserid],
          api_key: user[:api_key],
          first_name: user[:first_name],
          last_name: user[:last_name],
          email: user[:email_address],
          created_at: user[:created_at],
          updated_at: user[:updated_at]
        )
      end
    end
  end

  desc "Migrate watch lists"
  task :watch_lists => :environment do
    confirm(
      message: "All existing watch lists will be deleted! Also make sure to migrate users first! Continue?",
      token: "yes"
    )

    puts "Deleting existing watch lists..."
    WatchList.destroy_all

    puts "Migrating watch lists from old katalog..."
    WatchList.transaction do
      source_db[:watch_lists].each do |watch_list|
        print "."

        WatchList.create!(
          id: watch_list[:id],
          user_id: watch_list[:user_id],
          name: watch_list[:name],
          description: watch_list[:description].presence,
          created_at: watch_list[:created_at],
          updated_at: watch_list[:updated_at]
        )
      end
    end

    print "\n"
    puts "Migrating watch list entries from old katalog..."
    WatchListEntry.transaction do
      source_db[:watch_list_entries].each do |entry|
        print "."

        WatchListEntry.create!(
          id: entry[:id],
          watch_list_id: entry[:watch_list_id],
          record_id: entry[:record_id],
          scope: entry[:scope_id],
          created_at: entry[:created_at],
          updated_at: entry[:updated_at]
        )
      end
    end
  end

  desc "Migrate notes"
  task :notes => :environment do
    confirm(
      message: "All existing notes will be deleted! Also make sure to migrate users first! Continue?",
      token: "yes"
    )

    puts "Deleting existing notes..."
    Note.destroy_all

    puts "Migrating notes from old katalog..."
    Note.transaction do
      source_db[:notes].each do |note|
        print "."

        Note.create!(
          id: note[:id],
          user_id: note[:user_id],
          record_id: note[:record_id],
          scope: note[:scope_id],
          value: note[:value].presence,
          created_at: note[:created_at],
          updated_at: note[:updated_at]
        )
      end
    end
  end

  desc "Fix local record IDs for watch list entries and notes."
  task :fix_local_record_ids => :environment do
    confirm(
      message: "Make sure search index is up to date and watch lists and notes have been migrated! Continue?",
      token: "yes"
    )

    fixer = ->(batch) {
      Parallel.each(batch, in_threads: 5) do |entry|
        if entry.record_id.length == 9
          # We found an old record
          if resolved_record = resolve_local_record(entry.record_id)
            # The record still exists with a new Alma ID
            # Update record ID
            puts "OK: #{entry.record_id} => #{resolved_record.id}"
            entry.update(record_id: resolved_record.id, record_id_migrated: true)
          else
            # The record doesn't exists anymore
            puts "FAILED: #{entry.record_id}"
            entry.update(record_id_migrated: true)
          end
        else
          # The record has been migrated already
          puts "SKIPPED: #{entry.record_id}"
          entry.update(record_id_migrated: true)
        end
      end
    }

    puts "Fixing record IDs and scope in watch list entries..."
    WatchListEntry
      .where(scope: "local")
      .where(record_id_migrated: false)
      .find_in_batches do |batch|
        fixer.(batch)
    end

    puts "Fixing record IDs and scope in notes..."
    Note
      .where(scope: "local")
      .where(record_id_migrated: false)
      .find_in_batches do |batch|
        fixer.(batch)
    end
  end

  desc "Fix CDI record IDs for watch list entries and notes."
  task :fix_cdi_record_ids => :environment do
    confirm(
      message: "Make sure watch lists and notes have been migrated! Continue?",
      token: "yes"
    )

    fixer = ->(batch) {
      Parallel.each(batch, in_threads: 5) do |entry|
        if entry.record_id.starts_with?("cdi_")
          # The record id is a CDI ID. Just update the scope.
          puts "OK: #{entry.record_id}"
          entry.update(scope: "cdi", record_id_migrated: true)
        else
          # The record id is an old Primo Central ID
          if resolved_record = resolve_cdi_record(entry.record_id)
            # The record still exists with new CDI ID
            # Update scope and record ID
            puts "OK: #{entry.record_id} => #{resolved_record.id}"
            entry.update(scope: "cdi", record_id: resolved_record.id, record_id_migrated: true)
          else
            # The record doesn't exists anymore
            puts "FAILED: #{entry.record_id}"
            entry.update(record_id_migrated: true)
          end
          # Do not stress CDI too much
          sleep(rand(0.1..0.5))
        end
      end
    }

    puts "Fixing record IDs and scope in watch list entries..."
    WatchListEntry
      .where(scope: "primo_central")
      .where(record_id_migrated: false)
      .find_in_batches do |batch|
        fixer.(batch)
    end

    puts "Fixing record IDs and scope in notes..."
    Note
      .where(scope: "primo_central")
      .where(record_id_migrated: false)
      .find_in_batches do |batch|
        fixer.(batch)
    end
  end

  desc "Migrate permalinks"
  task :permalinks => :environment do
    confirm(
      message: "All existing permalinks will be deleted! Continue?",
      token: "yes"
    )

    puts "Deleting existing permalinks..."
    Permalink.destroy_all

    puts "Migrating permalinks from old katalog..."
    Permalink.transaction do
      source_db[:permalinks].each do |link|
        print "."

        Permalink.create!(
          id: link[:id],
          key: link[:key],
          scope: link[:scope],
          search_request: link[:search_request],
          last_resolved_at: link[:last_resolved_at],
          created_at: link[:created_at],
          updated_at: link[:updated_at]
        )
      end
    end
  end

private

  def source_db
    @__source_db ||= Sequel.connect(
      adapter:  "mysql2",
      host:     ENV["SOURCE_DB_HOST"].presence || "localhost",
      user:     ENV["SOURCE_DB_USER"].presence,
      password: ENV["SOURCE_DB_PASSWORD"].presence,
      database: ENV["SOURCE_DB_NAME"].presence
    )
  end

  def confirm(message:, token:)
    STDOUT.puts "#{message}. Enter '#{token}' to confirm:"
    input = STDIN.gets.chomp
    raise "Aborting. You entered '#{input}'" if input != token
  end

  def resolve_local_record(aleph_id)
    # First look in our new search index for a record with the given Aleph ID
    resolved_record = SearchEngine["local"].get_record(aleph_id, by_other_id: "aleph_id")
    # If this record can not be found, we need to query the old search index
    # to get the HBZ ID. The HBZ ID can than be found in the new search index.
    # This happens to elektronic records, that where activated using the p2e process.
    # These records loose their Aleph ID in Alma.
    if resolved_record.nil?
      if (hbz_id = get_hbz_id_from_old_search_index(aleph_id)).present?
        resolved_record = SearchEngine["local"].get_record(hbz_id, by_other_id: "hbz_id")
      end
    end

    resolved_record
  end

  def resolve_cdi_record(record_id)
    SearchEngine["cdi"].get_record(record_id, on_campus: true)
  end

  def get_hbz_id_from_old_search_index(aleph_id)
    Oj.load(
      RestClient.get("http://131.234.233.138:9200/katalog/_doc/#{aleph_id}").body
    ).dig("_source", "ht_number")
  rescue RestClient::ExceptionWithResponse
    nil
  end

end
