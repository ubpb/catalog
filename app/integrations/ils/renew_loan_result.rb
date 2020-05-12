class Ils
  class RenewLoanResult < BaseStruct
    attribute :loan_id, Ils::Types::String
    attribute :success, Ils::Types::Bool.default(false)
    attribute :message, Ils::Types::String.optional
  end
end
