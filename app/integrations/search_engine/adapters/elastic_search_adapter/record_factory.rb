module SearchEngine::Adapters
  class ElasticSearchAdapter
    class RecordFactory

      def self.build(data)
        self.new.build(data)
      end

      def build(data)
        SearchEngine::Record.new(
          id: data["_id"],
          hbz_id: source_value(data, "ht_number"),
          zdb_id: source_value(data, "zdb_id"),
          selection_codes: normalize_array(source_value(data, "selection_code")),
          signature: source_value(data, "signature"),
          notations: normalize_array(source_value(data, "notation")),

          content_type: source_value(data, "inhaltstyp_facet").to_sym,
          media_type: source_value(data, "erscheinungsform_facet").to_sym,
          carrier_type: source_value(data, "materialtyp_facet").to_sym,

          is_superorder: source_value(data, "is_superorder"),
          is_secondary_form: source_value(data, "is_secondary_form"),

          title: source_value(data, "title_display").presence || "n.n.",
          creators_and_contributors: normalize_array(source_value(data, "creator_contributor_display")),
          year_of_publication: source_value(data, "creationdate"),
          edition: source_value(data, "edition"),
          publishers: normalize_array(source_value(data, "publisher")),
          format: source_value(data, "format"),
          languages: normalize_array(source_value(data, "language")),
          identifiers: build_identifiers(data),
          subjects: normalize_array(source_value(data, "subject")),
          descriptions: normalize_array(source_value(data, "description")),
          notes: normalize_array(source_value(data, "local_comment")),

          resource_links: build_resource_links(data),
          fulltext_links: build_fulltext_links(data),
          part_of: build_part_of(data),
          source: build_source(data),
          relations: build_relations(data),

          journal_stocks: build_journal_stocks(data)
        )
      end

    private

      def source_value(data, key)
        data["_source"][key]
      end

      # Some data fields are sometimes Arrays and sometimes Strings
      # depending on their cardinality.
      def normalize_array(string_hash_or_array)
        case string_hash_or_array
        when Array        then string_hash_or_array
        when String, Hash then [string_hash_or_array]
        else []
        end
      end

      def build_identifiers(data)
        identifiers = []
        # ISBN
        normalize_array(source_value(data, "isbn")).each do |value|
          identifiers << SearchEngine::Identifier.new(type: :isbn, value: value)
        end
        # ISSN
        normalize_array(source_value(data, "issn")).each do |value|
          identifiers << SearchEngine::Identifier.new(type: :issn, value: value)
        end
        # other
        normalize_array(source_value(data, "identifier")).each do |identifier|
          identifiers << SearchEngine::Identifier.new(type: identifier.type.to_sym, value: identifier.value)
        end
        # Return identifiers
        identifiers
      end

      def build_resource_links(data)
        links = []
        # Create links
        normalize_array(source_value(data, "resource_links")).each do |link|
          links << SearchEngine::Link.new(url: link["url"], label: link["label"])
        end
        # Return links
        links
      end

      def build_fulltext_links(data)
        links = []
        # Create links
        normalize_array(source_value(data, "fulltext_links")).each do |link|
          links << SearchEngine::Link.new(url: link)
        end
        # Filter / sort links
        links = ResourceLinksFilter.new(links).filter
        # Return links
        links
      end

      def build_part_of(data)
        part_of = []

        normalize_array(source_value(data, "is_part_of")).each do |part_of_data|
          label = part_of_data["label"]
          label << ": #{[*part_of_data["label_additions"]].join(", ")}" if part_of_data["label_additions"].present?
          label << "; #{part_of_data["volume_count"]}" if part_of_data["volume_count"].present?

          part_of << SearchEngine::Relation.new(label: label, id: part_of_data["ht_number"])
        end

        part_of
      end

      def build_source(data)
        if source_data = source_value(data, "source").presence
          label = [source_data["label"], source_data["counting"]].compact.join(". ")

          SearchEngine::Relation.new(label: label, id: source_data["ht_number"])
        end
      end

      def build_relations(data)
        relations = []
        # Create relations
        normalize_array(source_value(data, "relation")).each do |relation|
          relations << SearchEngine::Relation.new(label: relation["label"], id: relation["ht_number"])
        end
        # Return relations
        relations
      end

      def build_journal_stocks(data)
        stocks = []

        normalize_array(source_value(data, "journal_stock")).each do |journal_stock|
          stocks << SearchEngine::Journal.new(
            stocks: normalize_array(journal_stock["stock"]),
            gaps: normalize_array(journal_stock["gaps"]),
            signature: journal_stock["signature"],
            label: journal_stock["leading_text"]
          )
        end

        stocks
      end

    end
  end
end
