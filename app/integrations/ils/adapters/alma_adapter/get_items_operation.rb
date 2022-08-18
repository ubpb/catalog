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
        # Alma uses offset and limit for pagination
        offset = 0
        limit  = 100

        # Load the first 100 items from Alma
        response = load_items(record_id, offset: offset, limit: limit)
        # Get total number of items
        total_number_of_items = response["total_record_count"] || 0

        # Build array of item objects
        items = []
        items += response["item"] || []

        # Fetch the rest if there are more items
        if limit < total_number_of_items
          while (offset = offset + limit) < total_number_of_items
            response = load_items(record_id, offset: offset, limit: limit)
            items += response["item"] || []
          end
        end

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
      end

      def load_items(record_id, limit:, offset:)
        adapter.api.get(
          "bibs/#{record_id}/holdings/ALL/items",
          format: "application/json",
          params: {
            expand: "due_date_policy,due_date",
            limit: limit,
            offset: offset
          }
        )
      rescue
        {}
      end

    end
  end
end
