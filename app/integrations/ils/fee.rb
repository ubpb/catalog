class Ils
  class Fee < BaseStruct
    attribute :id, Types::String
    attribute :type, Types::String
    attribute :date, Types::Time
    attribute :balance, Types::Float.default(0.0)
    attribute :title, Types::String.optional
    attribute :barcode, Types::String.optional
  end
end
