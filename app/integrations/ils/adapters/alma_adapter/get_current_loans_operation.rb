module Ils::Adapters
  class AlmaAdapter
    class GetCurrentLoansOperation < GetLoansBase

      def loan_status
        "Active"
      end

      def expand
        "renewable"
      end

    end
  end
end
