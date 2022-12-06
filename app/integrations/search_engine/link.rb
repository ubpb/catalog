class SearchEngine
  class Link < BaseStruct
    attribute :label, Types::String.optional
    attribute :url, Types::String
    attribute :coverage, Types::String.optional
    attribute :note, Types::String.optional
  end
end
