module Ils::Adapters
  class AlmaAdapter
    class RenewLoanOperation < Operation

      def call(user_id, loan_id)
        response = adapter.api.post("users/#{user_id}/loans/#{loan_id}", params: {
          op: "renew"
        })

        Ils::RenewLoanResult.new(loan_id: loan_id, success: true, message: response.dig("last_renew_status", "desc"))
      rescue AlmaApi::Error => e
        Ils::RenewLoanResult.new(loan_id: loan_id, success: false, message: e.message)
      end

    end
  end
end
