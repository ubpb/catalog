module Ils::Adapters
  class AlmaAdapter
    class GetHoldRequestsForRecordOperation < Operation

      def call(record_id)
        get_hold_requests(record_id).map do |_|
          HoldRequestFactory.build(_)
        end
      end

    private

      def get_hold_requests(record_id)
        adapter.api.get(
          "bibs/#{record_id}/requests",
          params: {
            #request_type: "HOLD"
          }
        ).try(:[], "user_request") || []
      rescue ExlApi::LogicalError
        []
      end

    end
  end
end
