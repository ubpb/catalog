module Ils::Adapters
  class AlmaAdapter
    class GetHoldingsOperation < Operation

      def call(record_id)
        # Get all items for that record id
        get_holdings(record_id).map do |_|
          HoldingFactory.build(_)
        end
      end

    private

      def get_holdings(record_id)
        # load holdings from Alma
        response = load_holdings(record_id)

        # Build array of holding objects
        holdings = []
        holdings += response["holding"] || []

        # Filter out holdings with we don't want in discovery
        holdings = holdings.reject do |h|
          # Unassigned holdings
          h.dig("location", "value") =~ /UNASSIGNED/ ||
          # Items that are suppressed from publishing
          # For whatever reason this boolean flag is of type string.
          h.dig("suppress_from_publishing") == "true" ||
          # Holdings at location LL (Ausgesondert)
          h.dig("location", "value") == "LL"
        end
      end

      def load_holdings(record_id)
        adapter.api.get(
          "bibs/#{record_id}/holdings",
          format: "application/json"
        )
      rescue
        {}
      end

    end
  end
end
