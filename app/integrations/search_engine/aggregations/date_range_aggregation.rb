class SearchEngine
  class Aggregations::DateRangeAggregation < Aggregations::Base

    class Range < BaseStruct
      attribute :key,   Types::String
      attribute :from,  Types::Date.optional
      attribute :to,    Types::Date.optional
      attribute :count, Types::Integer.default(0)
    end

    attribute :ranges, Types::Array.of(Range)

  end
end
