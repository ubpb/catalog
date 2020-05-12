module Ils::Adapters
  class AlmaAdapter
    class GetCurrentLoansOperation < Operation

      LIMIT = 50

      def call(user_id)
        offset = 0
        item_loans  = []

        response = get_loans(user_id, offset: offset, limit: LIMIT)
        total_record_count = response["total_record_count"] || 0
        item_loans += response["item_loan"] || []

        if LIMIT < total_record_count
          while (offset = offset + LIMIT) < total_record_count
            response = get_loans(user_id, offset: offset, limit: LIMIT)
            item_loans += response["item_loan"]
          end
        end

        item_loans
          .select{|_| _["loan_status"].upcase == "ACTIVE"}
          .map{|_| LoanFactory.build(_)}
      end

    private

      def get_loans(user_id, offset:, limit:)
        adapter.api.get("users/#{user_id}/loans", params: {
          expand: "renewable",
          order_by: "due_date",
          limit: limit,
          offset: offset
        })
      end

    end
  end
end
