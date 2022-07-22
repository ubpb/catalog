module Ils::Adapters
  class AlmaAdapter
    class GetItemsOperation < Operation

      def call(record_id)
        # Get all items for that record id
        get_items(record_id).map do |_|
          ItemFactory.build(_)
        end
      end

    private

      def get_items(record_id)
        items = adapter.api.get(
          "bibs/#{record_id}/holdings/ALL/items",
          format: "application/json",
          params: {
            expand: "due_date_policy,due_date",
            #view: "label",
            limit: 100 # TODO: Add pagination to show more than 100 items
          }
        ).try(:[], "item") || []

        # Filter out items with we don't want in discovery
        items = items.reject do |i|
          # Unassigned holdings
          i.dig("item_data", "location", "value") =~ /UNASSIGNED/ ||
          # Items that are suppressed from publishing
          # For whatever reason this boolean flag is of type string.
          i.dig("holding_data", "holding_suppress_from_publishing") == "true" ||
          # Items at location LL (Ausgesondert)
          i.dig("item_data", "location", "value") == "LL"
        end
      rescue ExlApi::LogicalError
        []
      end

    end
  end
end
