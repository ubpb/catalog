module SearchEngine::Adapters
  class PrimoCentralAdapter < BaseAdapter
    include SearchEngine::Contract

    attr_reader :xclient

    def initialize(options = {})
      super
      @xclient = XServiceClient.new(options[:xservice_base_url], options[:institution])
    end

  end
end
