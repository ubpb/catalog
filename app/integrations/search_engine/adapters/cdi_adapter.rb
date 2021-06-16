module SearchEngine::Adapters
  class CdiAdapter < SearchEngine::Adapter
    include SearchEngine::Contract

    def initialize(options = {})
      super
    end

  end
end
