module Ils::Adapters
  class AlmaAdapter
    class GetCurrentLoansOperation < Operation

      PER_PAGE_DEFAULT = 2
      PER_PAGE_MAX     = 100
      PAGE_DEFAULT     = 1

      def call(user_id, options = {})
        # Setup required paging options with proper values
        per_page = per_page_value(options[:per_page])
        page     = page_value(options[:page])

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
          total_number_of_loans: total_number_of_loans
        )
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

      def per_page_value(value)
        value = value.to_i
        value = (value <= 0) ? PER_PAGE_DEFAULT : value
        (value >= 100) ? PER_PAGE_MAX : value
      end

      def page_value(value)
        value = value.to_i
        (value <= 0) ? PAGE_DEFAULT : value
      end

    end
  end
end
