class SearchEngine
  class JournalStock < BaseStruct
    attribute :label, Types::String
    attribute :call_number, Types::String
    attribute :location_name, Types::String
    attribute :location_code, Types::String
  end
end
