class Ils
  class User < BaseStruct
    attribute :id, Ils::Types::String
    attribute :first_name, Ils::Types::String.optional
    attribute :last_name, Ils::Types::String.optional
    attribute :email, Ils::Types::String.optional
    attribute :notes, Types::Array.of(Ils::Types::String).optional
  end
end
