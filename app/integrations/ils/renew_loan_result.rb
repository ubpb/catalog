class Ils
  class RenewLoanResult < BaseStruct
    attribute :loan, Ils::Loan
    attribute :success, Ils::Types::Bool.default(false)
    attribute :message, Ils::Types::String.optional
  end
end
