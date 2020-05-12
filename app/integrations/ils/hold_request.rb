class Ils
  class HoldRequest < BaseStruct
    attribute :id, Types::String
    attribute :status, Types::HoldRequestStatus
    attribute :deleteable, Types::Bool.default(false)
    attribute :begin_request_date, Types::Date
    attribute :end_request_date, Types::Date
    attribute :begin_hold_date, Types::Date.optional
    attribute :end_hold_date, Types::Date.optional
    attribute :queue_position, Types::Int.default(1)
    attribute :record, Record
  end
end
