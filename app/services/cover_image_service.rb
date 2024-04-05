class CoverImageService < ApplicationService

  class << self
    delegate :resolve, to: :new
  end

  #
  # Tries to find a cover image for the given record.
  #
  # @param [SearchEngine::Record] record The record from the search engine to find a cover image for.
  # @return [String] The cover image as data string.
  #
  def resolve(record)
    # Try LibKey
    if LibKeyService.enabled?
      url = LibKeyService.resolve_cover_image(record)
      return cover_image(url) if url.present?
    end

    # Try VLB
    if VlbService.enabled?
      url = VlbService.resolve_cover_image(record)
      return cover_image(url) if url.present?
    end

    # No cover image found
    placeholder_image
  end

  private

  def cover_image(url)
    Faraday.new(
      request: {
        timeout: 0.5
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
