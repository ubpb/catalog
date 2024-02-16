module Ils::Adapters
  class AlmaAdapter
    class SetUserPinOperation < Operation

      def call(user_id, pin)
        # Get the details for the user
        user_hash = adapter.api.get("users/#{CGI.escape(user_id)}")
        # Set the password
        user_hash["pin_number"] = pin
        # Update the user
        adapter.api.put("users/#{CGI.escape(user_id)}", body: user_hash.to_json)
        true
      rescue AlmaApi::LogicalError
        false
      end

    end
  end
end
