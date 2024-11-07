namespace :application do
  desc "Generate location lookup table"
  task generate_location_lookup_table: :environment do
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
  task cleanup_registrations: :environment do
    Registration.where("created_at < ?", 30.days.ago).destroy_all
    RegistrationRequest.where("created_at < ?", 7.days.ago).destroy_all
  end

  desc "Cleanup expired proxy users"
  task cleanup_expired_proxy_users: :environment do
    ProxyUser.includes(:user).where("expired_at < ?", Time.zone.today).find_each do |proxy_user|
      if ProxyUserService.delete_proxy_user_in_alma(
        proxy_user_ils_primary_id: proxy_user.proxy_user.ils_primary_id,
        proxy_for_user_ils_primary_id: proxy_user.user.ils_primary_id
      ) && proxy_user.destroy
        # Send email notification to the proxy user
        ProxyUsersMailer.proxy_user_expired_to_proxy_user(
          proxy_user_email: proxy_user.proxy_user.ils_user.email,
          proxy_user_name: proxy_user.proxy_user.ils_user.full_name,
          proxy_for_user_name: proxy_user.user.ils_user.full_name
        ).deliver

        # Send email notification to the user who created the proxy user
        ProxyUsersMailer.proxy_user_expired_to_proxy_for_user(
          proxy_user_name: proxy_user.proxy_user.ils_user.full_name,
          proxy_for_user_email: proxy_user.user.ils_user.email,
          proxy_for_user_name: proxy_user.user.ils_user.full_name
        ).deliver
      end
    end
  end

  desc "Sync proxy users"
  task sync_proxy_users: :environment do
    ProxyUserService.sync_proxy_users_with_alma(ProxyUser.all)
  end
end
