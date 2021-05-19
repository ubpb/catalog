module SearchEngine::Adapters
  class PrimoAdapter
    class RecordFactory

      def self.build(json)
        self.new.build(json)
      end

      def build(json)
        SearchEngine::Record.new(
          id: get_id(json),
          title: get_title(json),
          year_of_publication: get_year_of_publication(json),
          creators_and_contributors: get_creators_and_contributors(json),
          publishers: get_publishers(json),
          part_of: get_part_of(json),
          identifiers: get_identifiers(json),
          descriptions: get_descriptions(json),
          resolver_link: get_resolver_link(json),
          fulltext_links: get_fulltext_links(json),
          subjects: get_subjects(json),
          edition: get_edition(json),
          source: get_source(json),
          languages: get_languages(json)
        )
      end

    private

      def get_id(json)
        json.dig("pnx", "control", "recordid")&.first&.gsub(/\ATN_/, "")
      end

      def get_title(json)
        json.dig("pnx", "display", "title")&.first
      end

      def get_year_of_publication(json)
        json.dig("pnx", "search", "creationdate")&.first
      end

      def get_creators_and_contributors(json)
        cc = []
        cc += json.dig("pnx", "display", "creator") || []
        cc += json.dig("pnx", "display", "contributor") || []
        cc.map{|s| s.split(";").map(&:strip)}.flatten(1).map(&:presence).compact.uniq
      end

      def get_publishers(json)
        json.dig("pnx", "display", "publisher")
      end

      def get_part_of(json)
        json.dig("pnx", "display", "ispartof")&.map do |label|
          SearchEngine::Relation.new(label: label)
        end
      end

      def get_identifiers(json)
        identifiers = []

        json.dig("pnx", "addata", "issn")&.each do |issn|
          identifiers << SearchEngine::Identifier.new(type: :issn, value: issn)
        end

        json.dig("pnx", "addata", "eissn")&.each do |eissn|
          identifiers << SearchEngine::Identifier.new(type: :eissn, value: eissn)
        end

        json.dig("pnx", "addata", "doi")&.each do |doi|
          identifiers << SearchEngine::Identifier.new(type: :doi, value: doi)
        end

        identifiers
      end

      def get_descriptions(json)
        json.dig("pnx", "addata", "abstract")
      end

      def get_resolver_link(json)
        availability = json.dig("delivery", "availability")&.first

        unless availability =~ /linktorsrc/ # Ignore DirectLink resources
          if url = json.dig("delivery", "link")&.find{|l| l["linkType"] == "http://purl.org/pnx/linkType/openurl"}.try(:[], "linkURL")

            # Remove the language param to force the default language
            url = url.split('&').map{|e| e.gsub(/req\.language=.+/, 'req.language=')}.join('&')
            # See: https://github.com/ubpb/issues/issues/59
            url = url.gsub(/primo3-Article/i, "primo3-article")

            SearchEngine::ResolverLink.new(url: url, fulltext_available: availability == "fulltext")
          end
        end
      end

      def get_fulltext_links(json)
        links = []

        availability = json.dig("delivery", "availability")&.first

        if availability =~ /linktorsrc/ # Only DirectLink resources
          if url = json.dig("delivery", "link")&.find{|l| l["linkType"] == "http://purl.org/pnx/linkType/linktorsrc"}.try(:[], "linkURL")
            links << SearchEngine::Link.new(url: url)
          end
        end

        links
      end

      def get_subjects(json)
        subjects = json.dig("pnx", "search", "subject") || []
        subjects.map{|s| s.split(";").map(&:strip)}.flatten(1).map(&:presence).compact.uniq
      end

      def get_edition(json)
        json.dig("pnx", "display", "edition")&.first
      end

      def get_source(json)
        if source = json.dig("pnx", "display", "source")&.first
          SearchEngine::Relation.new(label: source)
        end
      end

      def get_languages(json)
        languages = json.dig("pnx", "display", "language") || []
        languages.map{|l| l.split(";").map(&:strip)}.flatten(1).map(&:presence).compact.uniq
      end

    end
  end
end
