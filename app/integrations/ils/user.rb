class Ils
  class User < BaseStruct
    attribute :id, Ils::Types::String
    attribute :user_group, Ils::UserGroup.optional
    attribute :first_name, Ils::Types::String.optional
    attribute :last_name, Ils::Types::String.optional
    attribute :email, Ils::Types::String.optional
    attribute :notes, Types::Array.of(Ils::Types::String).optional
    attribute :force_password_change, Ils::Types::Bool.default(false)
    attribute :barcode, Ils::Types::String.optional
    attribute :pin, Ils::Types::String.optional

    def has_pin_set?
      pin.present?
    end

    def full_name
      [first_name, last_name].map(&:presence).compact.join(" ")
    end

    def full_name_reversed
      [last_name, first_name].map(&:presence).compact.join(", ")
    end

    def short_barcode
      barcode&.at(0..-3)
    end

  end
end
