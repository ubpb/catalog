module SearchEngine::Adapters
  class CdiAdapter < SearchEngine::Adapter

    DEFAULT_API_TIMEOUT = 5.0

    include SearchEngine::Contract

    def initialize(options = {})
      super

      @api_timeout = options[:api_timeout].presence || DEFAULT_API_TIMEOUT
    end

    def http_client
      Faraday.new(
        request: {
          open_timeout: @api_timeout,
          timeout: @api_timeout
        },
        headers: {
          accept: "application/xml",
          "content-type": "application/xml"
        }
      ) do |faraday|
        faraday.response :raise_error
      end
    end

  end
end
