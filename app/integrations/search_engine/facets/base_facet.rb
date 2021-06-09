class SearchEngine
  class Facets::BaseFacet < BaseStruct
    attribute :name,  Types::String
    attribute :field, Types::String
  end
end
