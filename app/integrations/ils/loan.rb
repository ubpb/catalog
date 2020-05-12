class Ils
  class Loan < BaseStruct
    attribute :id, Types::String
    attribute :loan_date, Types::Date
    attribute :due_date, Types::Date
    attribute :renewable, Types::Bool.default(false)
    attribute :item_id, Types::String
    attribute :record_id, Types::String
    attribute :barcode, Types::String
    attribute :call_number, Types::String
    attribute :fine, Types::Float.default(0.0)
    attribute :title, Types::String.optional
    attribute :author, Types::String.optional
    attribute :description, Types::String.optional

    def renewable?
      self.renewable == true
    end
  end
end
