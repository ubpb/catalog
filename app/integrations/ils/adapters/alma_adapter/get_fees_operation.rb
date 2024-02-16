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
        adapter.api.get("users/#{CGI.escape(user_id)}/fees",
          params: {
            status: "ACTIVE"
          }
        )
      end

    end
  end
end
