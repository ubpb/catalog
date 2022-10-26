module Ils::Adapters
  class AlmaAdapter
    class GetLoansBase < PagedOperation

      def call(user_id, options = {})
        # Call super to setup paged operation
        super

        # Alma uses offset and limit for pagination
        offset = options[:disable_pagination] ? 0 : (page - 1) * per_page
        limit  = options[:disable_pagination] ? 5 : per_page

        # Load loans from Alma
        response = get_loans(
          user_id,
          offset: offset,
          limit: limit,
          loan_status: loan_status,
          expand: expand,
          order_by: options[:order_by],
          direction: options[:direction]
        )

        # Get total number of loans
        total_number_of_loans = response["total_record_count"] || 0

        # Build array of loan objects
        loans  = []
        loans += response["item_loan"] || []

        # If pagination is disabled fetch all other loans
        if options[:disable_pagination] && (limit < total_number_of_loans)
          # Calculate a list of offsets so we can fetch the remaining loans in parallel
          offsets = []
          while (offset = offset + limit) < total_number_of_loans
            offsets << offset
          end

          # Load remaining loans in parallel to speed up the loading process
          # Parallel.map will maintain the order
          loans += Parallel.map(offsets, in_threads: 5) do |offset|
            response = get_loans(
              user_id,
              offset: offset,
              limit: limit,
              loan_status: loan_status,
              expand: expand,
              order_by: options[:order_by],
              direction: options[:direction]
            )
            response["item_loan"] || []
          end.flatten(1)
        end

        # Build loan objects the app will understand
        loans  = loans.map{|_| LoanFactory.build(_)}

        # Return a result
        Ils::GetLoansResult.new(
          loans: loans,
          total: total_number_of_loans,
          page: (options[:disable_pagination] ? nil : page),
          per_page: (options[:disable_pagination] ? nil : per_page)
        )
      end

      def loan_status
        # override in subclass
      end

      def expand
        # override in subclass
      end

    private

      def get_loans(user_id, offset:, limit:, expand: nil, loan_status: nil, order_by: nil, direction: nil)
        params = {
          limit: limit,
          offset: offset
        }

        params[:expand]      = expand if expand.present?
        params[:loan_status] = ["Active", "Complete"].find{|e| e == loan_status} || "Active"

        sortable_fields = adapter.current_loans_sortable_fields || []
        sortable_field  = sortable_fields.find{|f| f == order_by}  || adapter.current_loans_sortable_default_field
        direction       = ["asc", "desc"].find{|d| d == direction} || adapter.current_loans_sortable_default_direction

        if sortable_field
          params[:order_by]  = sortable_field
          params[:direction] = direction.upcase
        end

        adapter.api.get("users/#{user_id}/loans",
          format: "application/json",
          params: params
        )
      end

    end
  end
end
