module Ils::Adapters
  class AlmaAdapter
    class SetUserEmailOperation < Operation

      def call(user_id, new_email)
        # Get the details for the user
        user = adapter.api.get("users/#{user_id}")
        emails = user.dig("contact_info", "email")

        # Find preferred E-Mail
        preferred_email = emails.find do |email|
          email["preferred"] == true
        end

        if preferred_email.present?
          preferred_email["email_address"] = new_email
        else
          emails << {
            "email_address": new_email,
            "preferred": true,
            "description": nil,
            "segment_type"=>"Internal",
            "email_type"=>[{"value"=>"personal"}]
          }
        end

        adapter.api.put("users/#{user_id}", body: user.to_json)
        true
      rescue ExlApi::LogicalError
        false
      end

    end
  end
end
