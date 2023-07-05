class LinkResolverController < ApplicationController

  #
  # Utility class to store and access the context object
  # returned from Alma as part of the Open URL resolving.
  #
  # If Alma founds a matching record it adds additional keys to the
  # context object. The context object still contains the keys as they
  # were passed to Alma as part of the Open URL params. This may result
  # in multiple keys with different values (the original from the URL and the enhanced
  # from Alma). We assume that the last one of such multiple occurrences is the enhanced
  # one from Alma.
  #
  # We also assume that the value of the context hash is always an array to account for
  # multiple values for a given key.
  class Context
    def initialize(context_hash)
      @context_hash = context_hash
    end
    # # Accessor for values
    def values(id); @context_hash[id]; end
    def value(id); values(id)&.last; end
    def value_first(id); values(id)&.first; end
    # # Convenient methods for fields we use in the UI
    # def alma_id; value("rft.mms_id"); end

    def title
      if is_journal?
        return value("rft.jtitle") || value("rft.title")
      end

      value_first("rft.btitle").presence || value("rft.title")
    end
    def authors; values("rft.au")&.join("; "); end
    def publisher; value("rft.pub"); end
    def place_of_publication; value("rft.place"); end
    def date_of_publication; value("rft.pubdate"); end

    def is_book?; value("rft.btitle").present?; end
    def is_journal?; value("rft.jtitle").present?; end

  end

  class FulltextService
    def initialize(resolution_url:, keys:)
      @resolution_url = resolution_url
      @keys = keys
    end

    # Convenient methods for fields we use in the UI
    def fulltext_url = @resolution_url
    def package_name = @keys["package_display_name"]
    def is_free? = @keys["is_free"]
    def public_note = @keys["public_note"]

    def availability
      @keys["availability"]
        &.gsub("<br>", "; ")
        &.gsub("Available", "Verfügbar")
        &.gsub("from", "von")
        &.gsub("volume:", "Band:")
        &.gsub("issue:", "Heft:")
        &.gsub("until", "bis")
        &.gsub("Most recent", "Neuste")
        &.gsub("year(s)", "Jahr(e)")
        &.gsub("not available", "nicht verfügbar")
        &.gsub("available", "verfügbar")
        &.gsub("months", "Monate")
    end
    # def authentication_note; @keys["authentication_note"]; end
  end

  def show
    add_breadcrumb t("link_resolver.breadcrumb")

    # Check Open URL against Alma link Resolver if Open URL params present
    # in the request.
    alma_result = resolve_by_alma(open_url_params)
    return unless alma_result.present?

    # Get context
    @context = get_context(alma_result)
    # Get fulltext services
    @fulltext_services = get_fulltext_services(alma_result)
  end

private

  SERVICE_PRIORITY = [
    /unpaywall/i
  ].freeze

  def get_context(alma_result)
    context_hash = alma_result.xpath("//context_object/keys/key").each_with_object({}) do |key_node, memo|
      key, value = normalized_key_and_value(key_node)

      if key
        memo[key] ||= []
        memo[key] << value
      end

      memo
    end

    Context.new(context_hash)
  end

  def get_fulltext_services(alma_result)
    # Get service nodes from alma result
    services = alma_result.xpath("//context_services/context_service")

    # Reject services that are "filtered"
    services = services.reject do |service_node|
      service_node.xpath("./keys/key").find do |key_node|
        key_node.attr("id")&.downcase == "filtered" && key_node.text&.downcase == "true"
      end
    end

    # Select only "getFullTxt" and "getOpenAccessFullText"
    services = services.select do |service_node|
      service_type = service_node.attr("service_type").presence
      ["getFullTxt", "getOpenAccessFullText"].include?(service_type)
    end

    # Map remaining services
    services = services.map { |service_node|
      # Resolution URL
      resolution_url = service_node.at_xpath("resolution_url")&.text.presence

      # Keys
      keys = service_node.xpath("./keys/key").each_with_object({}) { |key_node, memo|
        key, value = normalized_key_and_value(key_node)
        memo[key] = value if key
        memo
      }.presence

      # Fix is_free for unpaywall
      keys["is_free"] = true if keys["package_display_name"] =~ /unpaywall/i

      next unless resolution_url
      next unless keys

      # Return service
      FulltextService.new(resolution_url:, keys:)
    }.compact

    # Sort services & return
    services.sort do |a, b|
      ia = SERVICE_PRIORITY.find_index { |regexp| regexp.match(a.package_name) } || 1000
      ib = SERVICE_PRIORITY.find_index { |regexp| regexp.match(b.package_name) } || 1000
      ia <=> ib
    end
  end

  def resolve_by_alma(open_url_params)
    if (base_url = Config[:link_resolver, :base_url])
      # We need to create the request url from the
      # open_url_params by hand
      request_params = []
      open_url_params.each do |key, values|
        values.each do |value|
          request_params << "#{key}=#{Addressable::URI.encode_component(
            value, Addressable::URI::CharacterClasses::UNRESERVED
          )}"
        end
      end

      # Call the Alma Link Resolver
      response = RestClient.get("#{base_url}?#{request_params.join('&')}")

      # Check response
      if response.code == 200 && response.headers[:content_type] =~ /text\/xml/
        Nokogiri::XML.parse(response.body).remove_namespaces!
      end
    end
  rescue RestClient::ExceptionWithResponse
    nil
  end

  def open_url_params
    # Open URL params like rft_id can occur multiple times.
    # So the internal format is:
    #   string_key => [string_value, ...]
    open_url_params = {}

    # We can't rely on Rails params, because Open URL params
    # can occur multiple times.
    Addressable::URI
      .parse(request.fullpath)
      .query_values(Array)
      &.each do |key, value|
        open_url_params[key] ||= []
        open_url_params[key] << value
      end

    # Add params that are required by the Alma link resolver
    if open_url_params.present?
      open_url_params = open_url_params.merge(
        "svc_dat"       => ["CTO"],
        "response_type" => ["xml"],
        "ctx_enc"       => ["info:ofi/enc:UTF-8"],
        "ctx_ver"       => ["Z39.88-2004"],
        "url_ver"       => ["Z39.88-2004"]
        # "user_ip"       => [request.remote_ip]
      )
    end

    # Return
    open_url_params
  end

  # key_node example: <key id="rft.title">$ foo Perl-Magazin</key>
  def normalized_key_and_value(key_node)
    # Get clean key
    key = key_node.attr("id")
                  &.underscore
                  &.downcase
                  &.squish
                  &.tr(" ", "_")
                  .presence

    # Get clean value
    value = case key_node.text&.downcase
            when "0", "no", "false" then false
            when "1", "yes", "true" then true
            else key_node.text.presence
            end

    # Return key and value
    [key, value]
  end

end
