class Ils
  class Item < BaseStruct
    attribute :id, Types::String
    attribute :call_number, Types::String.optional
    attribute :barcode, Types::String.optional
    attribute :is_available, Types::Bool.default(false)
    attribute :reshelving_time, Types::Time.optional
    attribute :policy, Ils::ItemPolicy.optional
    attribute :library, Ils::Library.optional
    attribute :location, Ils::Location.optional
    attribute :process_type, Ils::ProcessType.optional
    attribute :due_date, Types::Time.optional
    attribute :due_date_policy, Types::String.optional
    attribute :is_requested, Types::Bool.default(false)
    attribute :notes, Types::String.optional
    attribute :expected_arrival_date, Types::Date.optional
    attribute :description, Types::String.optional

    def expected?
      process_type&.code == "ACQ" && expected_arrival_date.present?
    end

  end
end
