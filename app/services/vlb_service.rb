class VlbService < ApplicationService

  ENABLED = Config[:cover_images, :enabled, default: false]
  BASE_URL = Config[:cover_images, :base_url, default: "https://api.vlb.de/api/v1/cover"]
  ACCESS_TOKEN = Config[:cover_images, :access_token, default: ""]

  class << self
    delegate :resolve_cover_image, to: :new

    def enabled?
      ENABLED && BASE_URL.present? && ACCESS_TOKEN.present?
    end
  end

  #
  # Tries to find a cover image for the given record.
  #
  # @param [SearchEngine::Record] record The record from the search engine to find a cover image for.
  # @return [String, nil] The URL of the cover image. If no url is found we return nil.
  #
  def resolve_cover_image(record)
    isbn = record.first_isbn13 if record&.respond_to?(:first_isbn13)
    return nil if isbn.blank?

    "#{BASE_URL}/#{isbn}/m?access_token=#{ACCESS_TOKEN}"
  rescue
    nil
  end

end
