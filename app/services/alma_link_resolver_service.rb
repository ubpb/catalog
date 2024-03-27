class AlmaLinkResolverService < ApplicationService

  SERVICE_PRIORITY = [
    /unpaywall/i
  ].freeze

  def resolve(open_url_string)
    # Parse Open URL params
    open_url_params = parse_open_url(open_url_string)

    puts "open_url_params: #{open_url_params}"
  end

  private

  def api_client
    Faraday.new(
      headers: {
        accept: "text/xml",
        "content-type": "text/xml"
      }
    ) do |faraday|
      faraday.response :raise_error
    end
  end

  # Parses an Open URL string into a parameter hash that is suitable for .
  #
  # Open URL params like rft_id can occur multiple times.
  #
  # So the internal format is:
  #   {
  #      key => [value, value, ...],
  #      ...
  #   }
  def parse_open_url(open_url_string)
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
        # "user_ip"       => [request.remote_ip]
      )
    end

    # Return
    open_url_params
  end

end
