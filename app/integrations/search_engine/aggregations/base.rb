class SearchEngine
  class Aggregations::Base < BaseStruct
    attribute :name,  Types::String
    attribute :field, Types::String
  end
end
