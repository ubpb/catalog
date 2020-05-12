class SearchEngine
  class Hit < BaseStruct
    attribute :score, Types::Float.default(0.0)
    attribute :record, Record
  end
end
