module AlmaApi
  class Configuration

    attr_reader :api_key
    attr_reader :api_base_url
    attr_reader :default_format
    attr_reader :language

    def api_key=(value)
      @api_key = value.presence || ENV["ALMA_API_KEY"].presence

      unless @api_key
        raise ArgumentError, "Missing API key. A key is required."
      end
    end

    def api_base_url=(value)
      base_url = value.presence || ENV["ALMA_API_BASE_URL"].presence || "https://api-eu.hosted.exlibrisgroup.com/almaws/v1"
      @api_base_url = base_url.ends_with?("/") ? base_url[0..-2] : base_url
    end

    def default_format=(value)
      @default_format = value.presence || ENV["ALMA_API_DEFAULT_FORMAT"].presence || "application/json"

      unless @default_format == "application/json" || @default_format == "application/xml"
        raise ArgumentError, "Unsupported format '#{@default_format}'. Only 'application/json' and 'application/xml' is supported."
      end
    end

    def language=(value)
      @language = value.presence || ENV["ALMA_API_LANGUAGE"].presence || "en"
    end

  end
end
