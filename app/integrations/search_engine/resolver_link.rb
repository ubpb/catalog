class SearchEngine
  class ResolverLink < BaseStruct
    attribute :url, Types::String
    attribute :fulltext_available, Types::Bool.default(false)
  end
end
