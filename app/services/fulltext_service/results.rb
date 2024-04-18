class FulltextService::Results
  include Enumerable

  attr_reader :results, :service_had_timeout, :alma_link_resolver_context

  def initialize(results: [], service_had_timeout: false, alma_link_resolver_context: nil)
    @results = results
    @service_had_timeout = service_had_timeout
    @alma_link_resolver_context = alma_link_resolver_context
  end

  alias_method :service_had_timeout?, :service_had_timeout

  delegate :each, to: :results

  delegate :empty?, to: :results

  delegate :[], to: :results

end
