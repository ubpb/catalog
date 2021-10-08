module Ils::Adapters
  class AlmaAdapter
    class GetItemsOperation < Operation

      def call(record_id)
        # Get all items for that record id
        items_result = get_items_result(record_id)

        # Return list of items
        items_result.map{|_| ItemFactory.build(_)}
      end

    private

      def get_items_result(record_id)
        adapter.api.get(
          "bibs/#{record_id}/holdings/ALL/items",
          format: "application/json",
          params: {
            expand: "due_date_policy,due_date",
            view: "label"
          }
        ).try(:[], "item")
      end

    end
  end
end
