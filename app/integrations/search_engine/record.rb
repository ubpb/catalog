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

    # Resource type
    attribute :resource_type, Types::String.default("unspecified")
    # Material type
    attribute :material_type, Types::String.default("unspecified")
    # Content type
    attribute :content_type, Types::String.default("unspecified")

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
    # Local notations
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


    def is_superorder?
      self.is_superorder
    end

    def is_online_resource?
      self.is_online_resource
    end

    def is_deleted?
      self.is_deleted
    end

  end
end
