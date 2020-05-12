class Ils
  class Record < BaseStruct
    attribute :id, Types::String
    attribute :signature, Types::String.optional
    attribute :title, Types::String.optional
    attribute :author, Types::String.optional
    attribute :year, Types::String.optional
  end
end
