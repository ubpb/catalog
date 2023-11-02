module Ils::Adapters
  class AlmaAdapter
    class SetUserPasswordOperation < Operation

      def call(user_id, password)
        # Get the details for the user
        body = adapter.api.get("users/#{user_id}")
        # Set the password
        body["password"] = password
        # Update the user
        adapter.api.put("users/#{user_id}", body: body.to_json)
        true
      rescue ExlApi::LogicalError
        false
      end

    end
  end
end
