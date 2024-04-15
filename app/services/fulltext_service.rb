class FulltextService < ApplicationService

  class << self
    delegate :resolve, to: :new
  end

  #
  # @return [FulltextService::Results] Fulltext results for the given record.
  #
  def resolve(record, only: nil)
    # Return nil if the record is blank.
    return nil if record.blank?
    # Return nil if the record is not an online resource.
    return nil unless record.is_online_resource?

    # Initialize variables
    service_had_timeout = false
    results = []

    # Try to resolve the fulltext links via LibKey if LibKey is enabled
    # and if the record has a DOI or PMID.
    if LibKeyService.enabled? &&
      (doi_or_pmid = record.first_doi || record.first_pmid).present? &&
      only?(only, "libkey")
      begin
        LibKeyService.resolve(doi_or_pmid)&.tap do |result|
          results << Result.new(
            source: "libkey",
            url: result.url,
            retraction_notice_url: result.retraction_notice_url,
            options: {
              browzine_url: result.browzine_url
            }
          )
        end
      rescue LibKeyService::TimeoutError
        service_had_timeout = true
      end
    end

    # If the record has fulltext links available, use them.
    # This is the case for local records that have been published by Alma General Publishing
    # and processed through our pub pipeline. This is also the case for CDI "direct link" records.
    if record.fulltext_links.present? &&
      only?(only, "record")
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

    # Try to resolve the fulltext links via Alma Link Resolver.
    # This is the case for CDI records that are not "direct link" records.
    # We use the open URL record information (that is part of the CDI record data)
    # to resolve the fulltext links with the Alma Link Resolver.
    if AlmaLinkResolverService.enabled? &&
      (openurl = record.resolver_link&.url).present? &&
      only?(only, "alma")
      begin
        AlmaLinkResolverService.resolve(openurl)&.fulltext_services&.tap do |services|
          services.each do |service|
            results << Result.new(
              source: "alma",
              url: service.fulltext_url,
              label: service.package_name,
              coverage: service.availability,
              note: service.public_note
            )
          end
        end
      rescue AlmaLinkResolverService::TimeoutError
        service_had_timeout = true
      end
    end

    # Return results
    Results.new(results: results, service_had_timeout: service_had_timeout)
  end

  private

  def only?(only, source)
    only.blank? ||
    (only.is_a?(String) && only.to_s == source) ||
    (only.is_a?(Array) && only.find {|e| e.to_s == source})
  end

end
