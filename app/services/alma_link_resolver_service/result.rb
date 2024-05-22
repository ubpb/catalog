class AlmaLinkResolverService
  class Result

    attr_reader :context, :fulltext_services

    def initialize(context:, fulltext_services:)
      @context = context
      @fulltext_services = fulltext_services
    end

  end
end
