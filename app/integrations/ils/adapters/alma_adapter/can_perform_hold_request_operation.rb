module Ils::Adapters
  class AlmaAdapter
    class CanPerformHoldRequestOperation < Operation

      def call(record_id, user_id)
        response = adapter.api.get(
          "bibs/#{record_id}/request-options",
          params: {
            user_id: user_id
          }
        )

        (response["request_option"] || [{}]).find do |op|
          op.dig("type", "value") == "HOLD"
        end.present?
      rescue AlmaApi::LogicalError
        nil
      end

    end
  end
end
