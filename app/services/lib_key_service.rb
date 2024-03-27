class LibKeyService < ApplicationService

  ENABLED          = Config[:lib_key, :enabled, default: false]
  API_KEY          = Config[:lib_key, :api_key, default: ""]
  LIBRARY_ID       = Config[:lib_key, :library_id, default: ""]
  API_TIMEOUT      = Config[:lib_key, :api_timeout, default: 2.0]
  CACHE_EXPIRES_IN = Config[:lib_key, :cache_expires_in, default: 24.hours]

  BASE_URL = "https://api.thirdiron.com/public/v1/libraries/#{LIBRARY_ID}/".freeze

  class Error < StandardError; end

  class DisabledError < Error; end

  def initialize
    raise DisabledError unless LibKeyService.enabled?
  end

  def self.enabled?
    ENABLED && API_KEY.present? && LIBRARY_ID.present?
  end

  def resolve(doi_or_pmid)
    id = doi_or_pmid
    raise ArgumentError, "DOI or PMID is required" if id.blank?

    Rails.cache.fetch("lib-key-#{id.parameterize}", expires_in: CACHE_EXPIRES_IN) do
      path = is_doi?(id) ? "articles/doi/#{id}" : "articles/pmid/#{id}"
      api_client.get(path)&.body
    end
  rescue Faraday::Error
    {}
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
