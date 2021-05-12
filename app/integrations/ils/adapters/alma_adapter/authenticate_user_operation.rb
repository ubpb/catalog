module Ils::Adapters
  class AlmaAdapter
    class AuthenticateUserOperation < Operation

      def call(user_id, password)
        adapter.api.post("users/#{user_id}", params: {password: password})
        true
      rescue ExlApi::LogicalError
        false
      end

    end
  end
end
