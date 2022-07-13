class SearchEngine
  class SecondaryForm < BaseStruct
    attribute :physical_description, Types::String.optional
    attribute :year_of_publication, Types::String.optional
    attribute :publication_notices, Types::String.optional
    attribute :is_part_of, Types::String.optional
  end
end
