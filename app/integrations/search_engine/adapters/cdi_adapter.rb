module SearchEngine::Adapters
  class CdiAdapter < SearchEngine::Adapter
    include SearchEngine::Contract

    def initialize(options = {})
      super
    end

    def http_client
      Faraday.new(
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
