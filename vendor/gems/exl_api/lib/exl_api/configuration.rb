module ExlApi
  class Configuration

    def api_key=(value)
      @api_key = value.presence
    end

    def api_key
      @api_key
    end

    def base_url=(value)
      base_url = value.presence
      @api_base_url = base_url&.ends_with?("/") ? base_url[0..-2] : base_url
    end

    def base_url
      @api_base_url || "https://api-eu.hosted.exlibrisgroup.com"
    end

    def default_format=(value)
      @default_format = ExlApi.validate_format!(value)
    end

    def default_format
      @default_format || "json"
    end

    def language=(value)
      @language = value.presence
    end

    def language
      @language || "en"
    end

  end
end
