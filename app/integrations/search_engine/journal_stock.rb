class SearchEngine
  class JournalStock < BaseStruct
    attribute :label_prefix, Types::String.optional
    attribute :label, Types::String
    attribute :gap, Types::String.optional
    attribute :location_name, Types::String
    attribute :location_code, Types::String
    attribute :call_number, Types::String
    attribute :comments, Types::Array.of(Types::String).default([].freeze)
  end
end
