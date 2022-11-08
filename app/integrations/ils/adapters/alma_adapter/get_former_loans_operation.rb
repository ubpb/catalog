module Ils::Adapters
  class AlmaAdapter
    class GetFormerLoansOperation < GetLoansBase

      def loan_status
        "Complete"
      end

      def sortable_fields
        adapter.former_loans_sortable_fields || []
      end

      def sortable_default_field
        adapter.former_loans_sortable_default_field
      end

      def sortable_default_direction
        adapter.former_loans_sortable_default_direction
      end

    end
  end
end
