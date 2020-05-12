class SearchEngine
  class Record < BaseStruct
    # Unique ID of the record. REQUIRED.
    attribute :id, Types::String
    # Hbz ID (HT....)
    attribute :hbz_id, Types::String.optional
    # ZDB ID
    attribute :zdb_id, Types::String.optional
    # Local selection codes (Selektionskennzeichen)
    attribute :selection_codes, Types::Array.of(Types::String).default([].freeze)
    # Local signature (Signatur)
    attribute :signature, Types::String.optional
    # Local notations (Systemstellen)
    attribute :notations, Types::Array.of(Types::String).default([].freeze)

    # Content type (e.g. bibliography, textbook, dissertation, ...)
    attribute :content_type, Types::Symbol.default(:other)
    # Media type (e.g. monograph, journal, newspaper, ...)
    attribute :media_type, Types::Symbol.default(:other)
    # Carrier type (e.g. print, online_resource, data_storage, ...)
    attribute :carrier_type, Types::Symbol.default(:other)

    # Is the record a superorder record (Überordnung)?
    attribute :is_superorder, Types::Bool.default(false)
    # Is the record a secondary form record (Sekundärform)
    attribute :is_secondary_form, Types::Bool.default(false)

    # The title of the record. REQUIRED.
    attribute :title, Types::String
    # Creators and contributors
    attribute :creators_and_contributors, Types::Array.of(Types::String).default([].freeze)
    # Year of publication
    attribute :year_of_publication, Types::String.optional
    # Edition of the record
    attribute :edition, Types::String.optional
    # List of publishers
    attribute :publishers, Types::Array.of(Types::String).default([].freeze)
    # Format info
    attribute :format, Types::String.optional
    # List of languages (3 letter language codes)
    attribute :languages, Types::Array.of(Types::String).default([].freeze)
    # List of additional identifiers (e.g. ISBN, ISSN, etc.)
    attribute :identifiers, Types::Array.of(Identifier).default([].freeze)
    # List of subject terms
    attribute :subjects, Types::Array.of(Types::String).default([].freeze)
    # List of descriptions
    attribute :descriptions, Types::Array.of(Types::String).default([].freeze)
    # List of notes
    attribute :notes, Types::Array.of(Types::String).default([].freeze)

    # List of links to online ressources for the record
    attribute :resource_links, Types::Array.of(Link).default([].freeze)
    # List of links to fulltexts of the record
    attribute :fulltext_links, Types::Array.of(Link).default([].freeze)

    # List of relations to other records
    attribute :part_of, Types::Array.of(Relation).default([].freeze)
    # A relation to another record that is the source of this record
    attribute :source, Relation.optional
    # A list of other related records, that belong to this record
    # (e.g. Vorgänger, Nachfolger, Parallelausgaben, etc.)
    attribute :relations, Types::Array.of(Relation).default([].freeze)

    # A list of journal records, describing the available journal stock if
    # this record is a journal.
    attribute :journal_stocks, Types::Array.of(Journal).default([].freeze)
  end
end
