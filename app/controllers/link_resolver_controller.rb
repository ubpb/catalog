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
    # def values(id); @context_hash[id]; end
    # def value(id); values(id)&.last; end
    # # Convenient methods for fields we use in the UI
    # def alma_id; value("rft.mms_id"); end
    # def title; value("rft.title"); end
    # def authors; value("rft.au"); end
    # def publisher; value("rft.pub"); end
    # def place_of_publication; value("rft.place"); end
    # def date_of_publication; value("rft.pubdate"); end
  end

  class FulltextService
    def initialize(resolution_url:, keys:)
      @resolution_url = resolution_url
      @keys = keys
    end
    # Convenient methods for fields we use in the UI
    def fulltext_url; @resolution_url; end
    def package_name; @keys["package_display_name"]; end
    def is_free?; @keys["is_free"]; end
    def public_note; @keys["public_note"]; end
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
    #def authentication_note; @keys["authentication_note"]; end
  end


  def show
    add_breadcrumb t("link_resolver.breadcrumb")

    # Check Open URL params against our local search index
    # Brauchen wir vielleicht gar nicht, weil Alma das ja eigentlich
    # wissen müsste. Benötigen Beispiel.
    # TODO

    if params.except(:action, :controller).blank?
      # The page was called without any Open URL params
    elsif alma_result = resolve_by_alma(get_open_url_params)
      # Check Open URL against Alma link Resolver

      #
      # Parse context.
      #
      context_hash = alma_result.xpath("//context_object/keys/key").inject({}) do |memo, key_node|
        key, value = normalized_key_and_value(key_node)

        if key
          memo[key] ||= []
          memo[key] << value
        end

        memo
      end
      @context = Context.new(context_hash)

      #
      # Parse services (only full text services for now)
      #
      @fulltext_services = alma_result.xpath("//context_services/context_service")
      # Reject services that are "filtered"
      .reject do |service_node|
        service_node.xpath("./keys/key").find do |key_node|
          key_node.attr("id")&.downcase == "filtered" && key_node.text&.downcase == "true"
        end
      end
      # Map remaining services
      .map do |service_node|
        # Service type
        service_type = service_node.attr("service_type").presence
        next unless service_type == "getFullTxt"

        # Resolution URL
        resolution_url = service_node.at_xpath("resolution_url")&.text.presence

        # Keys
        keys = service_node.xpath("./keys/key").inject({}) do |memo, key_node|
          key, value = normalized_key_and_value(key_node)
          memo[key] = value if key
          memo
        end.presence

        # Return service
        if resolution_url && keys
          FulltextService.new(
            resolution_url: resolution_url,
            keys: keys
          )
        end
      end
      # Dedup services
      # TODO: Verify which parameter we can use to dedub.
      # .uniq do |service|
      #   service.package_name
      # end
      # Compact list
      .compact
    end
  end

private

  def resolve_by_alma(open_url_params)
    if base_url = Config[:link_resolver, :base_url]
      response = RestClient.get(base_url,
        params: open_url_params
      )

      if response.code == 200 && response.headers[:content_type] =~ /text\/xml/
        Nokogiri::XML.parse(response.body).remove_namespaces!
      end
    end
  rescue RestClient::ExceptionWithResponse
    nil
  end

  def get_open_url_params
    open_url_params = {}

    # Extract all relevant parameters from the params hash
    params.except(:action, :controller).each do |key, value|
      open_url_params[key.to_sym] = value
    end

    # Required by Alma
    open_url_params.merge(
      "svc_dat": "CTO",
      "response_type": "xml",
      "ctx_enc": "info:ofi/enc:UTF-8",
      "ctx_ver": "Z39.88-2004",
      "url_ver": "Z39.88-2004",
      #"user_ip": request.remote_ip
    )
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
