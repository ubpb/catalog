class SearchEngine
  class Record < BaseStruct
    # When was the last time an item or electronic portfolio
    # was linked to the title (used for 'Neuerwerbungslisten')
    attribute :newtest_acquisition_date, Types::Date.optional
    # Was the record deleted or supressed for discovery?
    attribute :is_deleted, Types::Bool.default(false)
    # Is the record an online-resource?
    attribute :is_online_resource, Types::Bool.default(false)
    # Is the record a superorder
    attribute :is_superorder, Types::Bool.default(false)

    # Unique ID of the record. REQUIRED.
    attribute :id, Types::String
    # Old Aleph ID
    attribute :aleph_id, Types::String.optional
    # Hbz ID (HT....)
    attribute :hbz_id, Types::String.optional
    # ZDB ID
    attribute :zdb_id, Types::String.optional
    # List of additional identifiers (e.g. ISBN, ISSN, etc.)
    attribute :additional_identifiers, Types::Array.of(Identifier).default([].freeze)

    # The title of the record. REQUIRED.
    attribute :title, Types::String

    # List of Creators
    attribute :creators, Types::Array.of(Creator).default([].freeze)
    # Year of publication
    attribute :year_of_publication, Types::String.optional
    # Publication notices (place of publication & publisher)
    attribute :publication_notices, Types::Array.of(Types::String).default([].freeze)
    # Edition
    attribute :edition, Types::String.optional
    # Physical description
    attribute :physical_description, Types::String.optional

    # Languages
    attribute :languages, Types::Array.of(Types::String).default([].freeze)
    # Subjects
    attribute :subjects, Types::Array.of(Types::String).default([].freeze)
    # Lokal notations
    attribute :local_notations, Types::Array.of(Types::String).default([].freeze)
    # Notes
    attribute :notes, Types::Array.of(Types::String).default([].freeze)

    # Link to a host record that holds the items
    # for the record (Marc field 773)
    attribute :host_item_id, Types::String.optional

    # Is part of ...
    attribute :is_part_of, Types::Array.of(IsPartOf).default([].freeze)
    # A list of other related records, that belong to this record
    # (e.g. Vorgänger, Nachfolger, Parallelausgaben, etc.)
    attribute :relations, Types::Array.of(Relation).default([].freeze)
    # A special relation to another record that is the source of this record
    attribute :source, Relation.optional

    # Related resource links
    attribute :related_resource_links, Types::Array.of(Link).default([].freeze)
    # Fulltext links
    attribute :fulltext_links, Types::Array.of(Link).default([].freeze)
    # Resolver links
    attribute :resolver_link, ResolverLink.optional

    # If the title is a print journal, the journal_stocks lists
    # the locally available volumes of that journal.
    attribute :journal_stocks, Types::Array.of(JournalStock).default([].freeze)

    # # Local selection codes (Selektionskennzeichen)
    # attribute :selection_codes, Types::Array.of(Types::String).default([].freeze)
    # # Local signature (Signatur)
    # attribute :signature, Types::String.optional
    # # Local notations (Systemstellen)
    # attribute :notations, Types::Array.of(Types::String).default([].freeze)

    # # Content type (e.g. bibliography, textbook, dissertation, ...)
    # attribute :content_type, Types::Symbol.default(:other)
    # # Media type (e.g. monograph, journal, newspaper, ...)
    # attribute :media_type, Types::Symbol.default(:other)
    # # Carrier type (e.g. print, online_resource, data_storage, ...)
    # attribute :carrier_type, Types::Symbol.default(:other)

    # # Is the record a superorder record (Überordnung)?
    # attribute :is_superorder, Types::Bool.default(false)
    # # Is the record a secondary form record (Sekundärform)
    # attribute :is_secondary_form, Types::Bool.default(false)

    # # The title of the record. REQUIRED.
    # attribute :title, Types::String
    # # Creators and contributors
    # attribute :creators_and_contributors, Types::Array.of(Types::String).default([].freeze)
    # # Year of publication
    # attribute :year_of_publication, Types::String.optional
    # # Edition of the record
    # attribute :edition, Types::String.optional
    # # List of publishers
    # attribute :publishers, Types::Array.of(Types::String).default([].freeze)
    # # Format info
    # attribute :format, Types::String.optional
    # # List of languages (3 letter language codes)
    # attribute :languages, Types::Array.of(Types::String).default([].freeze)
    # # List of additional identifiers (e.g. ISBN, ISSN, etc.)
    # attribute :identifiers, Types::Array.of(Identifier).default([].freeze)
    # # List of subject terms
    # attribute :subjects, Types::Array.of(Types::String).default([].freeze)
    # # List of descriptions
    # attribute :descriptions, Types::Array.of(Types::String).default([].freeze)
    # # List of notes
    # attribute :notes, Types::Array.of(Types::String).default([].freeze)

    # # Link to link resolver
    # attribute :resolver_link, ResolverLink.optional
    # # List of links to online ressources for the record (TOCs, Thumbnails, etc.)
    # #attribute :resource_links, Types::Array.of(Link).default([].freeze)
    # # List of links to fulltexts of the record
    # attribute :fulltext_links, Types::Array.of(Link).default([].freeze)

    # # List of relations to other records
    # attribute :part_of, Types::Array.of(Relation).default([].freeze)
    # # A relation to another record that is the source of this record
    # attribute :source, Relation.optional


    # # A list of journal records, describing the available journal stock if
    # # this record is a journal.
    # attribute :journal_stocks, Types::Array.of(Journal).default([].freeze)
  end
end
