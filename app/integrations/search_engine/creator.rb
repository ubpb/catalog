class SearchEngine
  class Creator < BaseStruct
    attribute :name, Types::String
    attribute :relationships, Types::Array.of(Types::String).default([].freeze)
    attribute :authority_ids, Types::Array.of(AuthorityId).default([].freeze)
  end
end
