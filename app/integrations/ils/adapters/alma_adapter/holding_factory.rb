module Ils::Adapters
  class AlmaAdapter
    class HoldingFactory

      def self.build(holding)
        self.new.build(holding)
      end

      def build(holding)
        Ils::Holding.new(
          id: get_id(holding),
          call_number: get_call_number(holding),
          library: get_library(holding),
          location: get_location(holding)
        )
      end

    private

      def get_id(holding)
        holding.dig("holding_id").presence
      end

      def get_call_number(holding)
        holding.dig("call_number").presence
      end

      def get_library(holding)
        code  = holding.dig("library", "value").presence
        label = holding.dig("library", "desc").presence

        if code && label
          Ils::Library.new(code: code,label: label)
        end
      end

      def get_location(holding)
        code  = holding.dig("location", "value").presence
        label = holding.dig("location", "desc").presence

        if code && label
          Ils::Location.new(code: code,label: label)
        end
      end

    end
  end
end
