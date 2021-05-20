class Ils
  class GetLoansResult < BaseStruct
    attribute :loans, Types::Array.of(Loan).default([].freeze)
    attribute :total, Ils::Types::Integer.default(0)
    attribute :page, Ils::Types::Integer.optional
    attribute :per_page, Ils::Types::Integer.optional
  end
end
