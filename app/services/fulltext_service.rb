class FulltextService < ApplicationService

  #
  # @return [Array<FulltextService::Result>] A list of fulltext results for the given record.
  #   If no links are available, an empty array is returned.
  #
  def resolve(record)
    results = []
    return results unless record.is_online_resource?

    # If the record has fulltext links available, use them
    if record.fulltext_links.present?
      record.fulltext_links.each do |link|
        results << Result.new(url: link.url, source: "record")
      end
    end

    # Try to resolve the fulltext links via LibKey
    lib_key_service&.resolve(record)&.tap do |lib_key_result|
      url = lib_key_result.dig("data", "fullTextFile")
      results << Result.new(url: url, source: "libkey") if url.present?
    end

    # Try to resolve the fulltext links via Alma Link Resolver
    alma_link_resolver_service.resolve(record)&.fulltext_services&.tap do |services|
      services.each do |service|
        results << Result.new(url: service.fulltext_url, source: "alma")
      end
    end

    # Return results
    results
  end

  private

  def alma_link_resolver_service
    if AlmaLinkResolverService.enabled?
      @alma_link_resolver_service ||= AlmaLinkResolverService.new
    end
  end

  def lib_key_service
    if LibKeyService.enabled?
      @lib_key_service ||= LibKeyService.new
    end
  end

end
