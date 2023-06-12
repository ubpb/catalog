class Ils
  class User < BaseStruct
    attribute :id, Ils::Types::String
    attribute :user_group, Ils::UserGroup.optional
    attribute :first_name, Ils::Types::String.optional
    attribute :last_name, Ils::Types::String.optional
    attribute :email, Ils::Types::String.optional
    attribute :notes, Types::Array.of(Ils::Types::String).optional
    attribute :force_password_change, Ils::Types::Bool.default(false)
  end
end
