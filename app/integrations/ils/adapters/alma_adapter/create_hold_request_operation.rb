module Ils::Adapters
  class AlmaAdapter
    class CreateHoldRequestOperation < Operation

      def call(record_id, user_id)
        create_hold_request(record_id, user_id)
        true
      rescue AlmaApi::Error
        false
      end

    private

      def create_hold_request(record_id, user_id)
        adapter.api.post("users/#{CGI.escape(user_id)}/requests",
          params: {
            mms_id: record_id,
            allow_same_request: false
          },
          body: {
            "request_type": "HOLD",
            "pickup_location_type": "LIBRARY",
            "pickup_location_library": "P0001"
          }.to_json
        )
      end

    end
  end
end
