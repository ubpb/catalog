module Ils::Adapters
  class AlmaAdapter
    class GetSemappLocationOperation < Operation

      def call(record_id, item_id)
        loans = get_loans(record_id)

        user_id = loans.find{|loan| loan.dig("item_id") == item_id}&.dig("user_id")
        return nil if user_id.blank?

        user = get_user(user_id)

        if user.present? && (name = user.dig("full_name")) && (user.dig("user_group", "value") == "07")
          name
        else
          nil
        end
      end

    private

      def get_loans(record_id)
        loans = adapter.api.get(
          "bibs/#{CGI.escape(record_id)}/loans",
          params: {
            loan_status: "Active"
          }
        ).try(:[], "item_loan") || []
      rescue AlmaApi::LogicalError
        []
      end

      def get_user(user_id)
        adapter.api.get(
          "users/#{CGI.escape(user_id)}",
          params: {
            view: "brief"
          })
      rescue AlmaApi::LogicalError
        nil
      end

    end
  end
end
