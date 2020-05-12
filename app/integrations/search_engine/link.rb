class SearchEngine
  class Link < BaseStruct
    attribute :label, Types::String.optional
    attribute :url, Types::String
  end
end
