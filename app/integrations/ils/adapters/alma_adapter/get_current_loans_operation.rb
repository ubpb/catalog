module Ils::Adapters
  class AlmaAdapter
    class GetCurrentLoansOperation < GetLoansBase

      def loan_status
        "Active"
      end

      def expand
        "renewable"
      end

      def sortable_fields
        adapter.current_loans_sortable_fields || []
      end

      def sortable_default_field
        adapter.current_loans_sortable_default_field
      end

      def sortable_default_direction
        adapter.current_loans_sortable_default_direction
      end

    end
  end
end
