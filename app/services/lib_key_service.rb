class LibKeyService < ApplicationService

  ENABLED          = Config[:lib_key, :enabled, default: false]
  API_KEY          = Config[:lib_key, :api_key, default: ""]
  LIBRARY_ID       = Config[:lib_key, :library_id, default: ""]
  API_TIMEOUT      = Config[:lib_key, :api_timeout, default: 3.0]
  CACHE_EXPIRES_IN = Config[:lib_key, :cache_expires_in, default: 24.hours]

  BASE_URL = "https://api.thirdiron.com/public/v1/libraries/#{LIBRARY_ID}/".freeze

  class Error < StandardError; end

  class TimeoutError < Error; end

  class DisabledError < Error; end

  class << self
    delegate :resolve, to: :new

    def enabled?
      ENABLED && API_KEY.present? && LIBRARY_ID.present?
    end
  end

  def initialize
    raise DisabledError unless self.class.enabled?
  end

  def resolve(record)
    # Try to get the DOI or PMID from the record
    id = record.first_doi || record.first_pmid
    return nil if id.blank?

    # Resolve the fulltext link via LibKey
    Rails.cache.fetch("lib-key-#{record.id}", expires_in: CACHE_EXPIRES_IN) do
      # Call LibKey
      path = is_doi?(id) ? "articles/doi/#{id}" : "articles/pmid/#{id}"
      libkey_result = api_client.get(path)&.body
      return nil if libkey_result.blank?

      # Parse LibKey result
      url = libkey_result.dig("data", "fullTextFile")
      browzine_link = libkey_result.dig("data", "browzineWebLink")
      return nil if url.blank?

      # Return result
      Result.new(url: url, browzine_link: browzine_link)
    end
  rescue Faraday::TimeoutError
    raise TimeoutError
  rescue Faraday::Error
    nil
  rescue => e
    Rails.logger.error [e.message, *Rails.backtrace_cleaner.clean(e.backtrace)].join($/)
    raise Error
  end

  private

  def api_client
    @api_client ||= Faraday.new(
      BASE_URL,
      request: {
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