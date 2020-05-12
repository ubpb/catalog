class SearchEngine
  class Identifier < BaseStruct
    attribute :type, Types::Symbol
    attribute :value, Types::String
  end
end
