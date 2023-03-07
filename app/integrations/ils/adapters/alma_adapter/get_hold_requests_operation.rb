module Ils::Adapters
  class AlmaAdapter
    class GetHoldRequestsOperation < Operation

      def call(user_id)
        # Alma uses offset and limit for pagination
        offset = 0
        limit  = 10

        # Load the first 10 hold requests from Alma
        response = get_hold_requests(user_id, offset: offset, limit: limit)
        # Get total number of loans
        total_number_of_hold_requests = response["total_record_count"] || 0

        # Build array of hold request objects
        hold_requests  = []
        hold_requests += response["user_request"] || []

        # Fetch the rest if there are more hold requests
        if limit < total_number_of_hold_requests
          while (offset = offset + limit) < total_number_of_hold_requests
            response = get_hold_requests(user_id, offset: offset, limit: limit)
            hold_requests += response["user_request"] || []
          end
        end

        # For each hold request fetch detailed item information and
        # extract the item call number and add it to the hold request object as
        # "call_number".
        # This is required becuase the "user request" object from Alma
        # does not include the item call number for "HOLD" requests.
        Parallel.each(hold_requests, in_threads: 3) do |hr|
          next unless (barcode = hr["barcode"]).presence

          item = get_item_by_barcode(barcode)
          call_number = item.dig("item_data", "alternative_call_number").presence
          next unless call_number

          hr["call_number"] = call_number
        end

        # Build array of hold request objects
        hold_requests.map{|_| HoldRequestFactory.build(_)}
      end

    private

      def get_hold_requests(user_id, offset:, limit:)
        adapter.api.get(
          "users/#{user_id}/requests",
          format: "application/json",
          params: {
            request_type: "HOLD",
            status:       "active",
            limit:        limit,
            offset:       offset
          }
        )
      end

      def get_item_by_barcode(barcode)
        adapter.api.get(
          "items?item_barcode=#{barcode}",
          format: "application/json"
        )
      end

    end
  end
end
