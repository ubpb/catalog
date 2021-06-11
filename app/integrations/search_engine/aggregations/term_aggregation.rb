class SearchEngine
  class Aggregations::TermAggregation < Aggregations::Base

    class Term < BaseStruct
      attribute :count, Types::Integer.default(0)
      attribute :term,  Types::String
    end

    attribute :terms, Types::Array.of(Term)

  end
end
