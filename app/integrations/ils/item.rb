class Ils
  class Item < BaseStruct
    attribute :id, Types::String
    attribute :signature, Types::String
    attribute :collection_code, Types::String
    attribute :item_status_code, Types::String
    attribute :process_status_code, Types::String.optional
    attribute :process_status, Types::ProcessStatus
    attribute :availability_status, Types::AvailabilityStatus
    attribute :due_date, Types::Date.optional
    attribute :note, Types::String.optional
    attribute :hold_request_count, Types::Int.default(0)
    attribute :hold_request_allowed, Types::Bool.default(false)

    def expected?
      process_status == :expected && due_date.present?
    end

    def loaned?
      process_status == :loaned && due_date.present?
    end

  end
end
