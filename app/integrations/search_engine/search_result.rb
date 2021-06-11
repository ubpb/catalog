class SearchEngine
  class SearchResult < BaseStruct
    attribute :hits,         Types::Array.of(Hit).default([].freeze)
    attribute :aggregations, Types::Array.of(Aggregations::Base).default([].freeze)
    attribute :total,        Types::Integer.default(0)
    attribute :page,         Types::Integer.optional
    attribute :per_page,     Types::Integer.optional
  end
end
