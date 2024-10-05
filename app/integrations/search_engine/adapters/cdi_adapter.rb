module SearchEngine::Adapters
  class CdiAdapter < SearchEngine::Adapter

    API_TIMEOUT  = Config[:cdi, :api_timeout, default: 5.0]

    include SearchEngine::Contract

    def initialize(options = {})
      super
    end

    def http_client
      Faraday.new(
        request: {
          open_timeout: API_TIMEOUT,
          timeout: API_TIMEOUT
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
