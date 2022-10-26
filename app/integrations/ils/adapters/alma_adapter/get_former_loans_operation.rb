module Ils::Adapters
  class AlmaAdapter
    class GetFormerLoansOperation < GetLoansBase

      def loan_status
        "Complete"
      end

    end
  end
end
