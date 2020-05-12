module Ils::Adapters
  class AlmaAdapter
    class GetUserOperation < Operation

      def call(user_id)
        response = adapter.api.get("users/#{user_id}")
        UserFactory.build(response)
      end

    end
  end
end
