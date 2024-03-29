module Ils::Adapters
  class AlmaAdapter
    class GetUserOperation < Operation

      def call(user_id)
        response = adapter.api.get("users/#{CGI.escape(user_id)}")
        UserFactory.build(response)
      rescue AlmaApi::LogicalError
        nil
      end

    end
  end
end
