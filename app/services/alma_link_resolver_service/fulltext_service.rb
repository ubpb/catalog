class AlmaLinkResolverService
  #
  # Utility class to store and access the context service object for fulltext services
  # returned from Alma as part of the Open URL resolving.
  #
  class FulltextService

    class << self
      include Utils

      SERVICE_PRIORITY = [
        /unpaywall/i
      ].freeze

      #
      # Extracts the context service objects of type "getFullTxt" from the Alma Link Resolver result.
      # We normalize the keys and values to be more consistent. We also remove
      # keys with nil values.
      #
      # @return [Array<FulltextService>] Array of FulltextService objects
      #
      def parse(alma_result)
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
            key, value = normalize_key_and_value(key_node.attr("id"), key_node.text)
            memo[key] = value if key && !value.nil? # value is either nil, a string or a boolean
            memo
          }

          # Fix is_free for unpaywall
          keys["is_free"] = true if /unpaywall/i.match?(keys["package_display_name"])

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
    end

    def initialize(resolution_url:, keys:)
      @resolution_url = resolution_url
      @keys = keys
    end

    def fulltext_url = @resolution_url

    def package_name = @keys["package_display_name"]

    def is_free? = @keys["is_free"]

    def public_note = @keys["public_note"]

    # FIXME: This is a quick hack to get the availability string in german for the UI
    # We need to integrate this into i18n in a proper way.
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
  end
end
