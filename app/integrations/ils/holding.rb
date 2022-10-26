class Ils
  class Holding < BaseStruct
    attribute :id, Types::String
    attribute :call_number, Types::String.optional
    attribute :library, Ils::Library.optional
    attribute :location, Ils::Location.optional
  end
end
