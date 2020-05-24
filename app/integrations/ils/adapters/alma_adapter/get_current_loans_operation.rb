module Ils::Adapters
  class AlmaAdapter
    class GetCurrentLoansOperation < PagedOperation

      def call(user_id, options = {})
        # Call super to setup paged operation
        super

        # Alma uses offset and limit for pagination
        offset = (page - 1) * per_page
        limit  = per_page

        # Load loans from Alma
        response = get_loans(user_id, offset: offset, limit: limit)

        # Get total number of loans
        total_number_of_loans = response["total_record_count"] || 0

        # Build array of loan objects
        loans  = []
        loans += response["item_loan"] || []
        loans  = loans.map{|_| LoanFactory.build(_)}

        # Return a result
        Ils::GetLoansResult.new(
          loans: loans,
          total_number_of_loans: total_number_of_loans,
          page: page,
          per_page: per_page
        )
      end

    private

      def get_loans(user_id, offset:, limit:)
        adapter.api.get("users/#{user_id}/loans",
          format: "application/json",
          params: {
            expand: "renewable",
            order_by: "due_date",
            limit: limit,
            offset: offset
          }
        )
      end

    end
  end
end
