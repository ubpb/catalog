module SearchEngine::Adapters
  class ElasticSearchAdapter
    class RecordFactory

      def self.build(data)
        self.new.build(data)
      end

      def build(data)
        record = SearchEngine::Record.new(
          newtest_acquisition_date: get_newtest_acquisition_date(data),
          is_deleted: get_is_deleted(data),
          is_online_resource: get_is_online_resource(data),
          is_superorder: get_is_superorder(data),

          resource_type: get_resource_type(data),
          material_type: get_material_type(data),
          content_type: get_content_type(data),

          id: get_id(data),
          aleph_id: get_aleph_id(data),
          hbz_id: get_hbz_id(data),
          zdb_id: get_zdb_id(data),
          additional_identifiers: get_identifiers(data),

          title: get_title(data),
          creators: get_creators(data),
          year_of_publication: get_year_of_publication(data),
          publication_notices: get_publication_notices(data),
          edition: get_edition(data),
          physical_description: get_physical_description(data),

          languages: get_languages(data),
          subjects: get_subjects(data),
          local_notations: get_local_notations(data),
          notes: get_notes(data),

          host_item_id: get_host_item_id(data),
          is_part_of: get_is_part_of(data),
          relations: get_relations(data),

          related_resource_links: get_related_resource_links(data),
          fulltext_links: get_fulltext_links(data),
          resolver_link: get_resolver_link(data),

          journal_stocks: get_journal_stocks(data),

          secondary_form: get_secondary_form(data)
        )

        # pp data
        # puts "------"
        # pp record

        record
      end

    private

      def get_newtest_acquisition_date(data)
        date = source_value(data, "meta", "newtest_acquisition_date")
        Date.parse(date) if date
      end

      def get_is_deleted(data)
        source_value(data, "meta", "is_deleted")
      end

      def get_is_online_resource(data)
        source_value(data, "meta", "is_online_resource")
      end

      def get_is_superorder(data)
        source_value(data, "meta", "is_superorder")
      end

      def get_resource_type(data)
        source_value(data, "resource_type")
      end

      def get_material_type(data)
        source_value(data, "material_type")
      end

      def get_content_type(data)
        source_value(data, "content_type")
      end

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

      def get_identifiers(data)
        identifiers = []
        # ISBN
        normalize_array(source_value(data, "isbns")).each do |value|
          identifiers << SearchEngine::Identifier.new(type: :isbn, value: value)
        end
        # ISSN
        normalize_array(source_value(data, "issns")).each do |value|
          identifiers << SearchEngine::Identifier.new(type: :issn, value: value)
        end
        # other
        normalize_array(source_value(data, "additional_identifiers")).each do |identifier|
          identifiers << SearchEngine::Identifier.new(type: identifier["type"].to_sym, value: identifier["value"])
        end
        # Return identifiers
        identifiers
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

      def get_publication_notices(data)
        source_value(data, "publication_notices")
      end

      def get_edition(data)
        source_value(data, "edition")
      end

      def get_physical_description(data)
        source_value(data, "physical_description")
      end

      def get_languages(data)
        normalize_array(
          source_value(data, "languages")
        )
      end

      def get_subjects(data)
        normalize_array(
          source_value(data, "subjects")
        )
      end

      def get_local_notations(data)
        normalize_array(
          source_value(data, "local_notations")
        )
      end

      def get_notes(data)
        normalize_array(
          source_value(data, "notes")
        )
      end

      def get_host_item_id(data)
        source_value(data, "host_item_id")
      end

      def get_is_part_of(data)
        normalize_array(
          source_value(data, "is_part_of")
        ).map do |is_part_of_data|
          SearchEngine::IsPartOf.new(
            label: is_part_of_data["label"],
            id: is_part_of_data["id"]
          )
        end
      end

      def get_relations(data)
        normalize_array(
          source_value(data, "relations")
        ).map do |relation|
          SearchEngine::Relation.new(
            label: relation["label"],
            id: relation["id"]
          )
        end
      end

      def get_related_resource_links(data)
        normalize_array(
          source_value(data, "related_resource_links")
        ).map do |link_data|
          SearchEngine::Link.new(
            label: link_data["label"],
            url: link_data["url"]
          )
        end
      end

      def get_fulltext_links(data)
        normalize_array(
          source_value(data, "fulltext_links")
        ).map do |link_data|
          SearchEngine::Link.new(
            label: link_data["label"],
            url: link_data["url"]
          )
        end
      end

      def get_resolver_link(data)
        if url = source_value(data, "resolver_link")
          SearchEngine::ResolverLink.new(
            url: url.gsub("https://katalog.ub.uni-paderborn.de", ""),
            fulltext_available: false
          )
        end
      end

      def get_journal_stocks(data)
        normalize_array(
          source_value(data, "journal_stocks")
        ).map do |journal_stock|
          SearchEngine::JournalStock.new(
            label_prefix: journal_stock["label_prefix"],
            label: journal_stock["label"],
            gap: journal_stock["gap"],
            location_name: journal_stock["location_name"],
            location_code: journal_stock["location_code"],
            call_number: journal_stock["call_number"],
            comments: journal_stock["comments"]
          )
        end
      end

      def get_secondary_form(data)
        if sf_data = source_value(data, "secondary_form")
          SearchEngine::SecondaryForm.new(
            physical_description: sf_data["physical_description"],
            year_of_publication: sf_data["year_of_publication"],
            publication_notices: sf_data["publication_notices"],
            is_part_of: sf_data["is_part_of"]
          )
        end
      end

    private # Helper

      def source_value(data, key, *identifiers)
        data["_source"].dig(key, *identifiers).presence
      end

      # Data fields are sometimes Arrays and sometimes Strings
      # depending on their cardinality.
      def normalize_array(string_hash_or_array)
        case string_hash_or_array
        when Array        then string_hash_or_array
        when String, Hash then [string_hash_or_array]
        else []
        end
      end

    end
  end
end
