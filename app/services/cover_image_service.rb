class CoverImageService < ApplicationService

  ENABLED          = Config[:cover, :enabled, default: false]
  TIMEOUT          = Config[:cover, :timeout, default: 5.0]
  CACHE_EXPIRES_IN = Config[:cover, :cache_expires_in, default: 7.days]

  class << self
    delegate :resolve, to: :new

    def enabled?
      ENABLED
    end
  end

  #
  # Tries to find a cover image for the given record.
  #
  # @param [SearchEngine::Record] record The record from the search engine to find a cover image for.
  # @return [String] The cover image as data string.
  #
  def resolve(record, force: false)
    cache_key = Digest::MD5.hexdigest(record.id)

    Rails.cache.fetch("cover-image-#{cache_key}", expires_in: CACHE_EXPIRES_IN, force: force) do
      # Try LibKey
      if ENABLED && LibKeyService.enabled?
        url = LibKeyService.resolve_cover_image(record)
        return cover_image(url) if url.present?
      end

      # Try VLB
      if ENABLED && VlbService.enabled?
        url = VlbService.resolve_cover_image(record)
        return cover_image(url) if url.present?
      end

      # No cover image found
      placeholder_image
    end
  end

  private

  def cover_image(url)
    Faraday.new(
      request: {
        open_timeout: TIMEOUT,
        timeout: TIMEOUT
      }
    ) do |faraday|
      faraday.response :raise_error
    end.get(url)&.body
  rescue
    placeholder_image
  end

  def placeholder_image
    Rails.public_path.join("cover_image_placeholder.png").read
  end

end
