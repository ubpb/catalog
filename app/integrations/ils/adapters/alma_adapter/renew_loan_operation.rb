module Ils::Adapters
  class AlmaAdapter
    class RenewLoanOperation < Operation

      def call(user_id, loan_id)
        response = adapter.api.post("users/#{CGI.escape(user_id)}/loans/#{CGI.escape(loan_id)}",
          params: {
            op: "renew"
          }
        )

        loan = LoanFactory.build(response)

        Ils::RenewLoanResult.new(loan: loan, success: true, message: response.dig("last_renew_status", "desc"))
      rescue AlmaApi::LogicalError => e
        Ils::RenewLoanResult.new(loan: loan, success: false, message: e.message)
      end

    end
  end
end
