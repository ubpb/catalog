module AlmaApi
  class Configuration

    def api_key=(value)
      @api_key = value.presence
    end

    def api_key
      @api_key || ENV["ALMA_API_KEY"].presence
    end

    def api_base_url=(value)
      base_url = value.presence
      @api_base_url = base_url.ends_with?("/") ? base_url[0..-2] : base_url
    end

    def api_base_url
      @api_base_url || ENV["ALMA_API_BASE_URL"].presence || "https://api-eu.hosted.exlibrisgroup.com/almaws/v1"
    end

    def default_format=(value)
      @default_format = value.presence

      unless @default_format == "application/json" || @default_format == "application/xml"
        raise ArgumentError, "Unsupported format '#{@default_format}'. Only 'application/json' and 'application/xml' is supported."
      end
    end

    def default_format
      @default_format || ENV["ALMA_API_DEFAULT_FORMAT"].presence || "application/json"
    end

    def language=(value)
      @language = value.presence
    end

    def language
      @language || ENV["ALMA_API_LANGUAGE"].presence || "en"
    end

  end
end
