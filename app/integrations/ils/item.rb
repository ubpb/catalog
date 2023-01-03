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
    attribute :public_note, Types::String.optional
    attribute :expected_arrival_date, Types::Date.optional
    attribute :description, Types::String.optional

    attribute :temp_location, Ils::Location.optional
    attribute :temp_policy, Ils::ItemPolicy.optional
    attribute :temp_due_back_date, Types::Date.optional

    def expected?
      process_type&.code == "ACQ" && expected_arrival_date.present?
    end

    def closed_stack_orderable?
      if location&.code == "04"
        false
      elsif is_available && location&.label =~ /magazin/i
        true
      else
        false
      end
    end

  end
end
