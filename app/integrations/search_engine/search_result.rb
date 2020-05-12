class SearchEngine
  class SearchResult < BaseStruct
    attribute :total, Types::Integer
    attribute :from, Types::Integer
    attribute :size, Types::Integer
    attribute :hits, Types::Array.of(Hit).default([].freeze)
  end
end
