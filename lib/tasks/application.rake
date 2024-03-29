namespace :application do
  desc "Generate location lookup table"
  task :generate_location_lookup_table => :environment do
    html = Nokogiri::HTML(Net::HTTP.get(URI("https://www.ub.uni-paderborn.de/nutzen-und-leihen/medienaufstellung-nach-systemstellen/")))
    medienaufstellung = html.css("table")

    lookup_table = []

    medienaufstellung.css("tr")[1..-1].each do |_row|
      if (cells = _row.css("td")).length > 1
        notation_range_min, notation_range_max = cells[0].content.split("-").map(&:strip).map(&:presence)

        lookup_table.push({
          systemstellen: notation_range_min..(notation_range_max || notation_range_min),
          fachgebiet: cells[1].content&.gsub(/\u00a0/, " ")&.gsub(/\t/, '')&.strip,
          location: cells[2].content&.gsub(/\u00a0/, " ")&.gsub(/\t/, '')&.strip,
          standortkennziffern: cells[3].content.gsub(/[^\d,]/, "").split(","),
          fachkennziffern: if cells[4].content.present?
            first, last = cells[4].content.gsub(/[^\d-]/, "").split("-")
            last ||= first
            if first && last
              Range.new(first, last).to_a
            else
              []
            end
          end
        })
      end
    end

    if lookup_table.present?
      filename = File.join(Rails.root, "config", "location_lookup_table.yml")
      File.write(
        filename,
        YAML.dump(lookup_table)
      )
      puts "File #{filename} written."
    else
      puts "Error: No data could be extracted."
    end
  end

  desc "Cleanup old registrations and registration requests"
  task :cleanup_registrations => :environment do
    Registration.where("created_at < ?", 30.days.ago).destroy_all
    RegistrationRequest.where("created_at < ?", 7.days.ago).destroy_all
  end

  # namespace :stimulus do
  #   namespace :manifest do
  #     STIMULUS_ROOT             = Rails.root.join("app/assets/src/application/js/stimulus")
  #     VIEW_COMPONENTS_ROOT      = Rails.root.join("app/components")
  #     STIMULUS_MANIFEST_PATH    = File.join(STIMULUS_ROOT, "index.js")
  #     STIMULUS_APPLICATION_PATH = "./application"

  #     task display: :environment do
  #       puts generate_manifest
  #     end

  #     task update: :environment do
  #       File.open(STIMULUS_MANIFEST_PATH, 'w+') do |index|
  #         index.puts <<~HEREDOC
  #           // This file is auto-generated by ./bin/rails application:stimulus:manifest:update'
  #           // Run that command whenever you add a new stimulus controller

  #           import { application } from "#{STIMULUS_APPLICATION_PATH}"

  #           #{generate_manifest}
  #         HEREDOC
  #       end
  #     end

  #   private

  #     def generate_manifest
  #       manifests = []
  #       manifests += generate_from(STIMULUS_ROOT)
  #       manifests += generate_from(VIEW_COMPONENTS_ROOT)
  #       manifests.join
  #     end

  #     def generate_from(controllers_path)
  #       extract_controllers_from(controllers_path).collect do |controller_path|
  #         import_and_register_controller(controllers_path, controller_path)
  #       end
  #     end

  #     def import_and_register_controller(controllers_path, controller_path)
  #       controller_path = controller_path.relative_path_from(controllers_path).to_s
  #       module_path = controller_path.split('.').first
  #       controller_class_name = module_path.camelize.gsub(/::/, "__")
  #       tag_name = module_path.remove(/_controller/).gsub(/_/, "-").gsub(/\//, "--")

  #       controller_full_path = Pathname.new(File.join(controllers_path, controller_path)).relative_path_from(Rails.root)
  #       import_root = controllers_path.relative_path_from(Pathname.new(File.dirname(STIMULUS_MANIFEST_PATH)))
  #       controller_path = File.join(import_root, controller_path)

  #       <<~HEREDOC
  #         // #{controller_full_path}
  #         import #{controller_class_name} from "#{controller_path}"
  #         application.register("#{tag_name}", #{controller_class_name})

  #       HEREDOC
  #     end

  #     def extract_controllers_from(directory)
  #       (directory.children.select { |e| e.to_s =~ /_controller(\.\w+)+$/ } +
  #         directory.children.select(&:directory?).collect { |d| extract_controllers_from(d) }
  #       ).flatten.sort
  #     end

  #   end
  # end
end

# if Rake::Task.task_defined?("stimulus:manifest:update")
#   Rake::Task["stimulus:manifest:update"].clear.enhance do
#     Rake::Task["application:stimulus:manifest:update"].invoke
#   end
# end

# if Rake::Task.task_defined?("stimulus:manifest:display")
#   Rake::Task["stimulus:manifest:display"].clear.enhance do
#     Rake::Task["application:stimulus:manifest:display"].invoke
#   end
# end
