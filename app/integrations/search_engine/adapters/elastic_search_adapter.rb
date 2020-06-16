module SearchEngine::Adapters
  class ElasticSearchAdapter < BaseAdapter
    include SearchEngine::Contract

    attr_reader :client

    def initialize(options = {})
      super
      @client = Elasticsearch::Client.new(options[:client_options])
    end

  end
end
