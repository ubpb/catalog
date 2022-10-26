class Ils
  class Loan < BaseStruct
    attribute :id, Types::String
    attribute :loan_date, Types::Time
    attribute :due_date, Types::Time
    attribute :return_date, Types::Time.optional
    attribute :renewable, Types::Bool.default(false)
    attribute :item_id, Types::String
    attribute :record_id, Types::String
    attribute :barcode, Types::String.optional
    attribute :fine, Types::Float.default(0.0)

    attribute :title, Types::String.optional
    attribute :author, Types::String.optional
    attribute :description, Types::String.optional
    attribute :year_of_publication, Types::String.optional

    attribute :is_resource_sharing_loan, Types::Bool.default(false)

    def renewable?
      renewable == true
    end

  end
end
