class Ils
  class HoldRequest < BaseStruct
    attribute :id, Types::String
    attribute :status, Types::HoldRequestStatus
    attribute :queue_position, Types::Integer.default(1)
    attribute :requested_at, Types::Time

    attribute :title, Types::String.optional
    attribute :author, Types::String.optional
    attribute :description, Types::String.optional
    attribute :barcode, Types::String.optional
  end
end
