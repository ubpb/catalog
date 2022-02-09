module Ils::Adapters
  class AlmaAdapter
    class GetItemsOperation < Operation

      def call(record_id)
        # Get all items for that record id
        alma_items = get_items(record_id) || []
        # Return list of items
        alma_items.map{|alma_item| ItemFactory.build(alma_item)}
      end

    private

      def get_items(record_id)
        adapter.api.get(
          "bibs/#{record_id}/holdings/ALL/items",
          format: "application/json",
          params: {
            expand: "due_date_policy,due_date",
            view: "label",
            limit: 100 # TODO: Add pagination to show more than 100 items
          }
        ).try(:[], "item")
      rescue ExlApi::LogicalError
        []
      end

      # def get_loan_info(record_id)
      #   adapter.api.get(
      #     "bibs/#{record_id}/loans",
      #     format: "application/json",
      #     params: {}
      #   )
      # end

      # def get_booking_info(record_id)
      #   adapter.api.get(
      #     "bibs/#{record_id}/booking-availability",
      #     format: "application/json",
      #     params: {
      #       period: 30,
      #       period_type: "days"
      #     }
      #   )
      # end

    end
  end
end
