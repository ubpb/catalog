class LibKeyController < ApplicationController

  ENABLED          = Config[:lib_key, :enabled, default: false]
  API_KEY          = Config[:lib_key, :api_key, default: ""]
  LIBRARY_ID       = Config[:lib_key, :library_id, default: ""]
  BASE_URL         = "https://api.thirdiron.com/public/v1/libraries/#{LIBRARY_ID}/".freeze
  API_TIMEOUT      = Config[:lib_key, :api_timeout, default: 2.0]
  IMAGE_TIMEOUT    = Config[:lib_key, :image_timeout, default: 0.5]
  CACHE_EXPIRES_IN = Config[:lib_key, :cache_expires_in, default: 24.hours]

  before_action :check_enabled

  def self.enabled?
    ENABLED && API_KEY.present? && LIBRARY_ID.present?
  end

  def json
    json = load_by_id(params[:id])
    render json: json
  end

  def pdf
    json = load_by_id(params[:id])
    return if json.blank?

    @pdf_url = json.dig("data", "fullTextFile")
    @browzine_url = json.dig("data", "browzineWebLink")
    @is_open_access = json.dig("data", "openAccess")
    @ill_url = json.dig("data", "ILLURL")
    @retraction_notice_url = json.dig("data", "retractionNoticeUrl")
  end

  def cover
    json = load_by_id(params[:id])

    cover_image_url = json["included"]&.first&.dig("coverImageUrl")
    image_response = load_image(cover_image_url)

    if image_response
      send_data image_response.body, type: image_response.headers["content-type"].presence || "application/octet-stream"
    else
      # transparent gif
      send_data Base64.decode64("R0lGODlhAQABAPAAAAAAAAAAACH5BAEAAAAALAAAAAABAAEAAAICRAEAOw=="), type: "image/gif"
    end
  end

  private

  def check_enabled
    unless self.class.enabled?
      head :not_found and return
    end

    true
  end

  def load_by_id(id)
    Rails.cache.fetch("lib-key-#{id}", expires_in: CACHE_EXPIRES_IN) do
      path = is_doi?(id) ? "articles/doi/#{id}" : "articles/pmid/#{id}"
      api_client.get(path)&.body
    end
  rescue Faraday::Error
    {}
  end

  def load_image(url)
    return nil if url.blank?

    response = Rails.cache.fetch("lib-key-image-#{url}", expires_in: CACHE_EXPIRES_IN) do
      image_client.get(url)
    end

    response.success? ? response : nil
  rescue Faraday::Error
    nil
  end

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

  def image_client
    @image_client ||= Faraday.new(
      BASE_URL,
      request: {
        timeout: 0.5
      }
    ) do |faraday|
      faraday.response :raise_error
    end
  end

  def is_doi?(id)
    id.start_with?("10.")
  end

end
