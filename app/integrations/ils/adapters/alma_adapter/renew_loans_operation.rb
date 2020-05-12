module Ils::Adapters
  class AlmaAdapter
    class RenewLoansOperation < Operation

      def call(user_id)
        # Get renewable loans for that user
        loans = GetCurrentLoansOperation.new(adapter).call(user_id).select{|loan| loan.renewable == true}
        # Renew all renewable loans
        loans.map do |loan|
          RenewLoanOperation.new(adapter).call(user_id, loan.id)
        end
      end

    end
  end
end
