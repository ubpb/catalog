class LibKeyService < ApplicationService

  ENABLED          = Config[:lib_key, :enabled, default: false]
  API_KEY          = Config[:lib_key, :api_key, default: ""]
  LIBRARY_ID       = Config[:lib_key, :library_id, default: ""]
  API_TIMEOUT      = Config[:lib_key, :api_timeout, default: 5.0]
  CACHE_EXPIRES_IN = Config[:lib_key, :cache_expires_in, default: 24.hours]

  BASE_URL = "https://api.thirdiron.com/public/v1/libraries/#{LIBRARY_ID}/".freeze

  class Error < StandardError; end

  class TimeoutError < Error; end

  class DisabledError < Error; end

  class << self
    delegate :resolve, to: :new
    delegate :resolve_cover_image, to: :new

    def enabled?
      ENABLED && API_KEY.present? && LIBRARY_ID.present?
    end
  end

  def initialize
    raise DisabledError unless self.class.enabled?
  end

  def resolve(doi_or_pmid)
    return nil if doi_or_pmid.blank?

    # Compute cache key
    cache_key = Digest::MD5.hexdigest(doi_or_pmid)

    # Resolve the fulltext link via LibKey
    Rails.cache.fetch("lib-key-#{cache_key}", expires_in: CACHE_EXPIRES_IN) do
      # Call LibKey
      path = is_doi?(doi_or_pmid) ? "articles/doi/#{doi_or_pmid}" : "articles/pmid/#{doi_or_pmid}"
      libkey_result = api_client.get(path)&.body
      return nil if libkey_result.blank?

      # Parse LibKey result
      url = libkey_result.dig("data", "fullTextFile")
      return nil if url.blank?
      # .. some optional values
      browzine_url = libkey_result.dig("data", "browzineWebLink")
      retraction_notice_url = libkey_result.dig("data", "retractionNoticeUrl")
      cover_image_url = libkey_result["included"]&.pluck("coverImageUrl")&.compact&.first

      # Return result
      Result.new(
        url: url,
        browzine_url: browzine_url,
        retraction_notice_url: retraction_notice_url,
        cover_image_url: cover_image_url
      )
    end
  rescue Faraday::TimeoutError
    raise TimeoutError
  rescue Faraday::Error
    nil
  rescue => e
    Rails.logger.error [e.message, *Rails.backtrace_cleaner.clean(e.backtrace)].join($/)
    raise Error
  end

  def resolve_cover_image(record)
    resolve(record)&.cover_image_url
  rescue
    nil
  end

  private

  def api_client
    @api_client ||= Faraday.new(
      BASE_URL,
      request: {
        open_timeout: API_TIMEOUT,
        timeout: API_TIMEOUT
      },
      params: {
        "include" => "journal"
      },
      headers: {
        "Authorization" => "Bearer #{API_KEY}"
      }
    ) do |faraday|
      faraday.response :raise_error
      faraday.response :json
    end
  end

  def is_doi?(id)
    id.start_with?("10.")
  end

end
