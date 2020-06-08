module Ils::Adapters
  class AlmaAdapter
    class RenewLoansOperation < Operation

      def call(user_id)
        # Get all loans for that user
        loans = GetCurrentLoansOperation.new(adapter)
          .call(user_id, disable_pagination: true)
          .loans
          .select{|loan| loan.renewable == true}

        # Renew all renewable loans
        Parallel.map(loans, in_threads: 5) do |loan|
          RenewLoanOperation.new(adapter)
            .call(user_id, loan.id)
        end
      end

    end
  end
end
