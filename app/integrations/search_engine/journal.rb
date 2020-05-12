class SearchEngine
  class Journal < BaseStruct
    attribute :signature, Types::String
    attribute :stocks, Types::Array.of(Types::String).default([].freeze)
    attribute :gaps, Types::Array.of(Types::String).default([].freeze)
    attribute :label, Types::String.optional
  end
end
