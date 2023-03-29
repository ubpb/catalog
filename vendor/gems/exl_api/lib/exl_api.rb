require "active_support"
require "active_support/core_ext"
require "rest_client"
require "nokogiri"
require "oj"

require "exl_api/configuration"

module ExlApi

  class Error < StandardError
    attr_reader :code

    def initialize(message, code)
      @code = code.presence || "UNKNOWN"
      super(message.presence || "Unknown cause")
    end
  end

  class GatewayError < Error ; end
  class ServerError  < Error ; end
  class LogicalError < Error ; end

  GATEWAY_ERROR_CODES = ["GENERAL_ERROR", "UNAUTHORIZED", "INVALID_REQUEST",
    "PER_SECOND_THRESHOLD", "REQUEST_TOO_LARGE", "FORBIDDEN", "ROUTING_ERROR"]

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

      call_with_error_handling do
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

      call_with_error_handling do
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

      call_with_error_handling do
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

      call_with_error_handling do
        RestClient.delete(
          full_uri(uri),
          accept: format,
          authorization: "apikey #{configuration.api_key}",
          params: get_params(params)
        )
      end
    end

  private

    def call_with_error_handling(&block)
      response = yield
      set_remaining_api_calls(response)
      parse_response(response)
    rescue RestClient::ExceptionWithResponse => e
      error = parse_error_response(e.response)

      case error[:error_code]
      when *GATEWAY_ERROR_CODES
        raise GatewayError.new(error[:error_message], error[:error_code])
      else
        case e.response.code
        when 400..499
          raise LogicalError.new(error[:error_message], error[:error_code])
        when 500..599
          raise ServerError.new(error[:error_message], error[:error_code])
        else # this should not happen
          raise ServerError.new(error[:error_message], error[:error_code])
        end
      end
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

    def parse_response(response)
      if response.body.present? && response.headers[:content_type].present?
        content_type = response.headers[:content_type]

        case content_type
        when /application\/json/
          Oj.load(response.body)
        when /text\/xml/, /application\/xml/
          Nokogiri::XML.parse(response.body)
        else
          raise ArgumentError, "Unsupported content type '#{content_type}' in response from API."
        end
      end
    end

    def parse_error_response(response)
      if response.body&.starts_with?("<") # XML
        xml = Nokogiri::XML.parse(response.body)
        error_message = xml.at("errorMessage")&.text
        error_code    = xml.at("errorCode")&.text

        return {error_message: error_message, error_code: error_code}
      end

      if response.body&.starts_with?("{") # JSON
        json = Oj.load(response.body)

        # Sometimes the format is:
        #   {"errorList":{"error":[{"errorCode":"xxx","errorMessage":"xxx"}]}}
        error_message = json.dig("errorList", "error", 0, "errorMessage")
        error_code    = json.dig("errorList", "error", 0, "errorCode")

        # Sometimes the format is:
        #   {"web_service_result":{"errorList":{"error":{"errorMessage":"xxx","errorCode":"xxx"}}}}
        error_message = json.dig("web_service_result", "errorList", "error", "errorMessage") if error_message.blank?
        error_code    = json.dig("web_service_result", "errorList", "error", "errorCode")    if error_code.blank?

        return {error_message: error_message, error_code: error_code}
      end

      # Otherwise...
      return {error_message: nil, error_code: nil}
    end

    def set_remaining_api_calls(response)
      rac = response.headers[:x_exl_api_remaining]
      @remaining_api_calls = rac.to_i if rac.present?
    end

  end
end
