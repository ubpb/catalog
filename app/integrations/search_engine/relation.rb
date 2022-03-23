class SearchEngine
  class Relation < BaseStruct
    attribute :label, Types::String
    attribute :id, Types::String.optional
  end
end
