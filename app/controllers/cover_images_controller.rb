require 'open-uri'

class CoverImagesController < ActionController::Base

  ENABLED      = Config[:cover_images, :enabled, default: false]
  BASE_URL     = Config[:cover_images, :base_url, default: "https://api.vlb.de/api/v1/cover"]
  ACCESS_TOKEN = Config[:cover_images, :access_token, default: ""]
  READ_TIMEOUT = Config[:cover_images, :read_timeout, default: 0.5]

  def show
    search_scope = params[:search_scope]
    id = params[:id]
    size = params[:size].presence || "m"
    
    # Load record by the given id
    record = SearchEngine[search_scope].get_record(id)

    isbn13 = record.additional_identifiers.select{|i| i.type == :isbn && i.value&.length >= 13}.first&.value&.gsub("-", "")&.delete(" ")

    if isbn13
      response = Rails.cache.fetch("cover-#{isbn13}-#{size}", expires_in: 24.hours) do
        load_cover_image(isbn13, size: size)
      end

      if response
        send_data response.body, disposition: "inline", type: response.content_type
        return
      end
    end

    # transparent gif
    send_data Base64.decode64("R0lGODlhAQABAPAAAAAAAAAAACH5BAEAAAAALAAAAAABAAEAAAICRAEAOw=="), disposition: "inline", type: "image/gif"
  end

private

  def load_cover_image(id, size: "m")
    if ENABLED && ACCESS_TOKEN.present?
      uri = URI.parse("#{BASE_URL}/#{id}/#{size}?access_token=#{ACCESS_TOKEN}")
      response = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
        http.read_timeout = READ_TIMEOUT
        request = Net::HTTP::Get.new(uri)
        http.request(request)
      end
      response if response.is_a?(Net::HTTPSuccess)
    end
  rescue Net::ReadTimeout
    nil
  end

end
