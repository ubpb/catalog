module Ils::Adapters
  class AlmaAdapter
    class DeleteUserBlockOperation < Operation

      def call(user_id, block_code)
        delete_user_block(user_id, block_code)
        true
      rescue AlmaApi::LogicalError
        false
      end

      private

      def delete_user_block(user_id, block_code)
        # Get user details
        body = adapter.api.get("users/#{user_id}")

        # Delete the block with the given code
        body["user_block"] = body["user_block"].reject do |block|
          block.dig("block_description", "value") == block_code
        end

        # Update the user
        adapter.api.put("users/#{user_id}", body: body.to_json)
      end
    end
  end
end
