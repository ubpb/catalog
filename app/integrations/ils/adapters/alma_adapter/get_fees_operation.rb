module Ils::Adapters
  class AlmaAdapter
    class GetFeesOperation < Operation

      def call(user_id)
        response = get_fees(user_id)

        fees = []
        fees += response["fee"] || []

        fees.map{|_| FeeFactory.build(_)}
      end

    private

      def get_fees(user_id)
        adapter.api.get("users/#{user_id}/fees",
          format: "application/json",
          params: {
            status: "ACTIVE"
          }
        )
      end

    end
  end
end
