module Ils::Adapters
  class AlmaAdapter
    class GetFormerLoansOperation < Operation

      def call(user_id)
        # By default, Alma doesn't store a loan history. This can be enabled,
        # but this brings privacy concerns. We need to discuss how we want to deal
        # with this. For now, we return an empty array.
        []
      end

    end
  end
end
