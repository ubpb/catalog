module SearchEngine::Adapters
  class ElasticSearchAdapter
    class RecordFactory

      def self.build(data)
        self.new.build(data)
      end

      def build(data)
        SearchEngine::Record.new(
          id: get_id(data),
          aleph_id: get_aleph_id(data),
          hbz_id: get_hbz_id(data),
          zdb_id: get_zdb_id(data),

          title: get_title(data),
          creators: get_creators(data),
          year_of_publication: get_year_of_publication(data),

          host_item_id: get_host_item_id(data)

          # edition: source_value(data, "edition"),
          # publishers: normalize_array(source_value(data, "publisher")),
          # format: source_value(data, "format"),
          # languages: normalize_array(source_value(data, "language")),
          # identifiers: build_identifiers(data),
          # subjects: normalize_array(source_value(data, "subject")),
          # descriptions: normalize_array(source_value(data, "description")),
          # notes: normalize_array(source_value(data, "local_comment")),

          # resource_links: build_resource_links(data),
          # fulltext_links: build_fulltext_links(data),
          # part_of: build_part_of(data),
          # source: build_source(data),
          # relations: build_relations(data),

          # journal_stocks: build_journal_stocks(data)
        )
      end

    private

      def get_id(data)
        data["_id"].presence
      end

      def get_aleph_id(data)
        source_value(data, "aleph_id")
      end

      def get_hbz_id(data)
        source_value(data, "hbz_id")
      end

      def get_zdb_id(data)
        source_value(data, "zdb_id")
      end

      def get_title(data)
        source_value(data, "title_display") || "n.n."
      end

      def get_creators(data)
        normalize_array(
          source_value(data, "creators")
        ).map do |creator_data|
          build_creator(creator_data)
        end
      end

      def build_creator(creator_data)
        SearchEngine::Creator.new(
          name: creator_data["name"],
          relationships: creator_data["relationships"],
          authority_ids: creator_data["authority_ids"].map{ |aid|
            SearchEngine::AuthorityId.new(
              type: aid["type"],
              id: aid["id"]
            )
          }
        )
      end

      def get_year_of_publication(data)
        source_value(data, "year_of_publication")&.dig("label")
      end

      def get_host_item_id(data)
        source_value(data, "host_item_id")
      end

    private # Helper

      def source_value(data, key)
        data["_source"][key].presence
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

      # def build_identifiers(data)
      #   identifiers = []
      #   # ISBN
      #   normalize_array(source_value(data, "isbn")).each do |value|
      #     identifiers << SearchEngine::Identifier.new(type: :isbn, value: value)
      #   end
      #   # ISSN
      #   normalize_array(source_value(data, "issn")).each do |value|
      #     identifiers << SearchEngine::Identifier.new(type: :issn, value: value)
      #   end
      #   # other
      #   normalize_array(source_value(data, "identifier")).each do |identifier|
      #     identifiers << SearchEngine::Identifier.new(type: identifier.type.to_sym, value: identifier.value)
      #   end
      #   # Return identifiers
      #   identifiers
      # end

      # def build_resource_links(data)
      #   links = []
      #   # Create links
      #   normalize_array(source_value(data, "resource_links")).each do |link|
      #     links << SearchEngine::Link.new(url: link["url"], label: link["label"])
      #   end
      #   # Return links
      #   links
      # end

      # def build_fulltext_links(data)
      #   links = []
      #   # Create links
      #   normalize_array(source_value(data, "fulltext_links")).each do |link|
      #     links << SearchEngine::Link.new(url: link)
      #   end
      #   # Filter / sort links
      #   links = ResourceLinksFilter.new(links).filter
      #   # Return links
      #   links
      # end

      # def build_part_of(data)
      #   part_of = []

      #   normalize_array(source_value(data, "is_part_of")).each do |part_of_data|
      #     label = part_of_data["label"]
      #     label << ": #{[*part_of_data["label_additions"]].join(", ")}" if part_of_data["label_additions"].present?
      #     label << "; #{part_of_data["volume_count"]}" if part_of_data["volume_count"].present?

      #     part_of << SearchEngine::Relation.new(label: label, id: part_of_data["ht_number"])
      #   end

      #   part_of
      # end

      # def build_source(data)
      #   if source_data = source_value(data, "source").presence
      #     label = [source_data["label"], source_data["counting"]].compact.join(". ")

      #     SearchEngine::Relation.new(label: label, id: source_data["ht_number"])
      #   end
      # end

      # def build_relations(data)
      #   relations = []
      #   # Create relations
      #   normalize_array(source_value(data, "relation")).each do |relation|
      #     relations << SearchEngine::Relation.new(label: relation["label"], id: relation["ht_number"])
      #   end
      #   # Return relations
      #   relations
      # end

      # def build_journal_stocks(data)
      #   stocks = []

      #   normalize_array(source_value(data, "journal_stock")).each do |journal_stock|
      #     stocks << SearchEngine::Journal.new(
      #       stocks: normalize_array(journal_stock["stock"]),
      #       gaps: normalize_array(journal_stock["gaps"]),
      #       signature: journal_stock["signature"],
      #       label: journal_stock["leading_text"]
      #     )
      #   end

      #   stocks
      # end

    end
  end
end
