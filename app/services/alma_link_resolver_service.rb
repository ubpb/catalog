class AlmaLinkResolverService < ApplicationService
  include Utils

  ENABLED  = Config[:alma_link_resolver, :enabled, default: false]
  BASE_URL = Config[:alma_link_resolver, :base_url]

  class Error < StandardError; end

  class DisabledError < Error; end

  class << self
    def enabled?
      ENABLED && BASE_URL.present?
    end
  end

  def initialize
    raise DisabledError unless self.class.enabled?
  end

  def resolve(open_url_string, user_ip: nil)
    # Parse Open URL params
    open_url_params = parse_open_url(open_url_string, user_ip: user_ip)
    return nil if open_url_params.blank?

    # Call Alma Link Resolver
    alma_result = resolve_by_alma(open_url_params)
    return nil if alma_result.blank?

    # Create context
    context = Context.parse(alma_result)

    # Get fulltext services
    fulltext_services = FulltextService.parse(alma_result)

    # Return result
    Result.new(context: context, fulltext_services: fulltext_services)
  end

  private

  def api_client
    @api_client ||= Faraday.new(
      headers: {
        accept: "text/xml",
        "content-type": "text/xml"
      }
    ) do |faraday|
      faraday.response :raise_error
    end
  end

  # Parses an Open URL string into a parameter hash that is suitable for querying the
  # Alma Link Resolver.
  #
  # @see https://developers.exlibrisgroup.com/alma/integrations/discovery/xml-openurl/
  #
  # Open URL params like rft_id can occur multiple times.
  #
  # So the internal format is (values are always arrays):
  #   {
  #      key => [value, value, ...],
  #      ...
  #   }
  def parse_open_url(open_url_string, user_ip: nil)
    open_url_params = {}

    # Parse
    Addressable::URI
      .parse(open_url_string)
      .query_values(Array)
      &.each do |key, value|
        open_url_params[key] ||= []
        open_url_params[key] << value
      end

    # Add params that are required by the Alma Link Resolver
    if open_url_params.present?
      open_url_params = open_url_params.merge(
        "svc_dat" => ["CTO"],
        "response_type" => ["xml"],
        "ctx_enc" => ["info:ofi/enc:UTF-8"],
        "ctx_ver" => ["Z39.88-2004"],
        "url_ver" => ["Z39.88-2004"]
      )

      # Add user_ip if given
      if user_ip.present?
        open_url_params["user_ip"] = [user_ip]
      end
    end

    # Return
    open_url_params
  end

  def resolve_by_alma(open_url_params)
    # Create a request string from the Open URL params hash we created
    # with #parse_open_url.
    request_params = []
    open_url_params.each do |key, values|
      values.each do |value|
        request_params << "#{key}=#{Addressable::URI.encode_component(
          value, Addressable::URI::CharacterClasses::UNRESERVED
        )}"
      end
    end

    # Call the Alma Link Resolver
    response = api_client.get("#{BASE_URL}?#{request_params.join("&")}")

    # Check response
    if response.status == 200 && response.headers[:content_type] =~ /text\/xml/
      Nokogiri::XML.parse(response.body).remove_namespaces!
    end
  rescue Faraday::Error
    nil
  rescue => e
    Rails.logger.error [e.message, *Rails.backtrace_cleaner.clean(e.backtrace)].join($/)
    raise Error
  end

end
