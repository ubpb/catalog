class Ils
  class GetLoansResult < BaseStruct
    attribute :loans, Types::Array.of(Loan).default([].freeze)
    attribute :total_number_of_loans, Ils::Types::Integer.default(0)
  end
end
