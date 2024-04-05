class FulltextService::Results
  include Enumerable

  attr_reader :results, :service_had_timeout

  def initialize(results: [], service_had_timeout: false)
    @results = results
    @service_had_timeout = service_had_timeout
  end

  alias_method :service_had_timeout?, :service_had_timeout

  delegate :each, to: :results

  delegate :empty?, to: :results

  delegate :[], to: :results

end
