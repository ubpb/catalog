require "csv"

namespace :application do
  desc "Import fixed history loans from CSV file"
  task :import_fixed_history_loans => :environment do
    unless filename = ENV["FILE"]
      puts "ERROR: Set FILE=\"path to csv file\""
      exit(1)
    end

    FixedHistoryLoan.transaction do
      FixedHistoryLoan.delete_all

      CSV.foreach(filename, col_sep: ";", quote_char: '"', headers: true) do |row|
        ils_primary_id = row[6].presence
        return_date    = Date.strptime(row[0], "%d.%m.%y")
        barcode        = row[1].presence
        alma_id        = row[2].presence
        title          = row[3].presence
        author         = row[4].presence

        if ils_primary_id && return_date && barcode
          FixedHistoryLoan.create!(
            ils_primary_id: ils_primary_id,
            return_date: return_date,
            barcode: barcode,
            alma_id: alma_id,
            title: title,
            author: author
          )
        else
          print "E"
        end

        print "."
      end
    end
  end
end
