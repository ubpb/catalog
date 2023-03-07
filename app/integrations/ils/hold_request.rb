class Ils
  class HoldRequest < BaseStruct
    attribute :id, Types::String
    attribute :record_id, Types::String.optional
    attribute :user_id, Types::String.optional # TODO: Remove .optional flag. This is only to fix the temp problem with broken hold requests.
    attribute :status, Types::HoldRequestStatus
    attribute :queue_position, Types::Integer.default(1)
    attribute :requested_at, Types::Time
    attribute :expiry_date, Types::Date.optional

    attribute :is_resource_sharing_request, Types::Bool.default(false)
    attribute :resource_sharing_status, Ils::ResourceSharingStatus.optional
    attribute :resource_sharing_id, Types::String.optional

    attribute :title, Types::String.optional
    attribute :author, Types::String.optional
    attribute :description, Types::String.optional
    attribute :barcode, Types::String.optional
    attribute :call_number, Types::String.optional
  end
end
