class FulltextService < ApplicationService

  class << self
    delegate :resolve, to: :new
  end

  #
  # @return [Array<FulltextService::Result>] A list of fulltext results for the given record.
  #   If no links are available, an empty array is returned.
  #
  def resolve(record)
    results = []
    return results unless record.is_online_resource?

    # If the record has fulltext links available, use them.
    # This is the case for local records that have been published by Alma General Publishing
    # and processed through our pub pipeline.
    # This is also the case for CDI "direct link" records.
    if record.fulltext_links.present?
      record.fulltext_links.each do |link|
        results << Result.new(
          source: "record",
          url: link.url,
          label: link.label,
          coverage: link.coverage,
          note: link.note
        )

        # Filter these results by priority and blacklist
        results = ResultFilter.filter(results)
      end
    end

    # Try to resolve the fulltext links via LibKey
    lib_key_service&.resolve(record)&.tap do |lib_key_result|
      lib_key_result.dig("data", "fullTextFile")&.tap do |url|
        results << Result.new(
          source: "libkey",
          url: url
        )
      end
    end

    # Try to resolve the fulltext links via Alma Link Resolver.
    # This is the case for CDI records that are not "direct link" records.
    # We use the open URL record information (that is part of the CDI record data)
    # to resolve the fulltext links with the Alma Link Resolver.
    alma_link_resolver_service&.resolve(record)&.fulltext_services&.tap do |services|
      services.each do |service|
        results << Result.new(
          source: "alma_link_resolver",
          url: service.fulltext_url,
          label: service.package_name,
          coverage: service.availability,
          note: service.public_note
        )
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
