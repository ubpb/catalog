class Ils
  class User < BaseStruct
    attribute :id, Ils::Types::String
    attribute :firstname, Ils::Types::String.optional
    attribute :lastname, Ils::Types::String.optional
    attribute :email, Ils::Types::String.optional
    attribute :notes, Types::Array.of(Ils::Types::String).optional

    def name
      [firstname, lastname].map(&:presence).compact.join(" ").presence
    end

    def name_reversed
      [lastname, firstname].map(&:presence).compact.join(", ").presence
    end

  end
end
