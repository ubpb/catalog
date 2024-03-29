module Ils::Adapters
  class AlmaAdapter
    class CancelHoldRequestOperation < Operation

      def call(user_id, hold_request_id)
        cancel_hold_request(user_id, hold_request_id)
        true
      rescue AlmaApi::LogicalError
        false
      end

    private

      def cancel_hold_request(user_id, hold_request_id)
        adapter.api.delete("users/#{CGI.escape(user_id)}/requests/#{CGI.escape(hold_request_id)}",
          params: {
            # Reason: Values from https://api-eu.hosted.exlibrisgroup.com/almaws/v1/conf/code-tables/RequestCancellationReasons?apikey=xxx
            reason: "PatronNotInterested",
            notify_user: true
          }
        )
      end

    end
  end
end
