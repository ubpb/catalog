module Ils::Adapters
  class AlmaAdapter
    class AuthenticateUserOperation < Operation

      def call(user_id, password)
        adapter.api.post("users/#{CGI.escape(user_id)}", params: {password: password})
        true
      rescue AlmaApi::LogicalError
        false
      end

    end
  end
end
