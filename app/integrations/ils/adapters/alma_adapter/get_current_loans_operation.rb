module Ils::Adapters
  class AlmaAdapter
    class GetCurrentLoansOperation < PagedOperation

      def call(user_id, options = {})
        # Call super to setup paged operation
        super

        # Alma uses offset and limit for pagination
        offset = options[:disable_pagination] ? 0 : (page - 1) * per_page
        limit  = options[:disable_pagination] ? 10 : per_page

        # Load loans from Alma
        response = get_loans(user_id, offset: offset, limit: limit)

        # Get total number of loans
        total_number_of_loans = response["total_record_count"] || 0

        # Build array of loan objects
        loans  = []
        loans += response["item_loan"] || []

        # If pagination is disabled fetch all other loans
        if options[:disable_pagination] && (limit < total_number_of_loans)
          while (offset = offset + limit) < total_number_of_loans
            response = get_loans(user_id, offset: offset, limit: limit)
            loans += response["item_loan"] || []
          end
        end

        # Build loan objects the app will understand
        loans  = loans.map{|_| LoanFactory.build(_)}

        # Return a result
        Ils::GetLoansResult.new(
          loans: loans,
          total_number_of_loans: total_number_of_loans,
          page: (options[:disable_pagination] ? nil : page),
          per_page: (options[:disable_pagination] ? nil : per_page)
        )
      end

    private

      def get_loans(user_id, offset:, limit:)
        adapter.api.get("users/#{user_id}/loans",
          format: "application/json",
          params: {
            expand: "renewable",
            order_by: "due_date",
            direction: "ASC",
            limit: limit,
            offset: offset
          }
        )
      end

    end
  end
end
