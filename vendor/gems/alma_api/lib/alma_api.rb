require "active_support"
require "active_support/core_ext"
require "rest_client"
require "nokogiri"
require "oj"

require "alma_api/configuration"

module AlmaApi

  class Error < StandardError ; end

  class << self

    attr_reader :remaining_api_calls

    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration) if block_given?
      self
    end

    def get(uri, params: {}, format: nil)
      format = get_format(format)

      call_with_error_handling format: format do
        RestClient.get(
          full_uri(uri),
          accept: format,
          authorization: "apikey #{configuration.api_key}",
          params: get_params(params)
        )
      end
    end

    def post(uri, params: {}, body: "", format: nil)
      format = get_format(format)

      call_with_error_handling format: format do
        RestClient.post(
          full_uri(uri),
          body,
          accept: format,
          "content-type": format,
          authorization: "apikey #{configuration.api_key}",
          params: get_params(params)
        )
      end
    end

    def put(uri, params: {}, body: "", format: nil)
      format = get_format(format)

      call_with_error_handling format: format do
        RestClient.put(
          full_uri(uri),
          body,
          accept: format,
          "content-type": format,
          authorization: "apikey #{configuration.api_key}",
          params: get_params(params)
        )
      end
    end

    def delete(uri, params: {}, format: nil)
      format = get_format(format)

      call_with_error_handling format: format do
        RestClient.delete(
          full_uri(uri),
          accept: format,
          authorization: "apikey #{configuration.api_key}",
          params: get_params(params)
        )
      end
    end

  private

    def call_with_error_handling(format:, &block)
      response = yield
      set_remaining_api_calls(response)
      parse_response(response, format)
    rescue RestClient::ExceptionWithResponse => e
      raise Error, parse_error_response(e.response, format)
    rescue e
      raise Error, e.message || "Unknown error"
    end

    def get_format(format)
      format || configuration.default_format
    end

    def get_params(params)
      params.reverse_merge(lang: configuration.language)
    end

    def full_uri(uri)
      if uri.starts_with?("http")
        uri
      else
        uri      = uri.starts_with?("/") ? uri[1..-1] : uri
        base_url = configuration.api_base_url
        "#{base_url}/#{uri}"
      end
    end

    def parse_response(response, format)
      case format
      when "application/json"
        Oj.load(response.body)
      when "application/xml"
        Nokogiri::XML.parse(response.body)
      else
        raise ArgumentError, "Unsupported format '#{format}'."
      end
    end

    def parse_error_response(response, format)
      case format
      when "application/json"
        json = Oj.load(response.body)

        if json["web_service_result"]
          json["web_service_result"]["errorList"]["error"]["errorMessage"]
        else
          json["errorList"]["error"][0]["errorMessage"]
        end
      when "application/xml"
        xml = Nokogiri::XML.parse(response.body)
        xml.at("errorMessage")&.text
      end
    rescue
      "Unknown error from Alma"
    end

    def set_remaining_api_calls(response)
      rac = response.headers[:x_exl_api_remaining]
      @remaining_api_calls = rac.to_i if rac.present?
    end

  end
end
