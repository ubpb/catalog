require "open-uri"

class CoverImagesController < ActionController::Base

  ENABLED = Config[:cover_images, :enabled, default: false]
  BASE_URL = Config[:cover_images, :base_url, default: "https://api.vlb.de/api/v1/cover"]
  ACCESS_TOKEN = Config[:cover_images, :access_token, default: ""]
  READ_TIMEOUT = Config[:cover_images, :read_timeout, default: 0.5]

  def show
    id = params[:id]
    size = params[:size].presence || "m"

    response = Rails.cache.fetch("cover-#{id}-#{size}", expires_in: 24.hours) do
      load_cover_image(id, size: size)
    end

    if response
      send_data response.body, disposition: "inline", type: response.content_type
    else
      # transparent gif
      send_data Base64.decode64("R0lGODlhAQABAPAAAAAAAAAAACH5BAEAAAAALAAAAAABAAEAAAICRAEAOw=="), disposition: "inline", type: "image/gif"
    end
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
  rescue Net::ReadTimeout, SocketError
    nil
  end

end
