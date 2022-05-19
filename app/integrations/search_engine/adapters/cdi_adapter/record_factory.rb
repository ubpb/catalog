module SearchEngine::Adapters
  class CdiAdapter
    class RecordFactory

      def self.build(xml)
        self.new.build(xml)
      end

      def build(xml)
        SearchEngine::Record.new(
          id: get_id(xml),
          title: get_title(xml),
          year_of_publication: get_year_of_publication(xml),
          creators_and_contributors: get_creators_and_contributors(xml),
          publishers: get_publishers(xml),
          is_part_of: get_is_part_of(xml),
          identifiers: get_identifiers(xml),
          descriptions: get_descriptions(xml),
          resolver_link: get_resolver_link(xml),
          fulltext_links: get_fulltext_links(xml),
          subjects: get_subjects(xml),
          edition: get_edition(xml),
          source: get_source(xml),
          languages: get_languages(xml)
        )
      end

    private

      def get_id(xml)
        xml.at_css("control recordid")&.text&.gsub(/\ATN_/, "")
      end

      def get_title(xml)
        xml.at_css("display title")&.text
      end

      def get_year_of_publication(xml)
        xml.at_css("search creationdate")&.text
      end

      def get_creators_and_contributors(xml)
        cc = []
        cc += xml.css("display creator")&.map(&:text) || []
        cc += xml.css("display contributor")&.map(&:text) || []
        cc.map{|s| s.split(";").map(&:strip)}.flatten(1).map(&:presence).compact.uniq
      end

      def get_publishers(xml)
        xml.css("display publisher")&.map(&:text)
      end

      def get_is_part_of(xml)
        xml.css("display ispartof")&.map(&:text)&.map do |label|
          SearchEngine::IsPartOf.new(label: label)
        end
      end

      def get_identifiers(xml)
        identifiers = []

        xml.css("addata issn")&.each do |issn|
          identifiers << SearchEngine::Identifier.new(type: :issn, value: issn.text)
        end

        xml.css("addata eissn")&.each do |eissn|
          identifiers << SearchEngine::Identifier.new(type: :eissn, value: eissn.text)
        end

        xml.css("addata doi")&.each do |doi|
          identifiers << SearchEngine::Identifier.new(type: :doi, value: doi.text)
        end

        identifiers
      end

      def get_descriptions(xml)
        xml.css("addata abstract")&.map(&:text)
      end

      def get_resolver_link(xml)
        if openurl = xml.at_css("LINKS openurl")&.text
          if u_params = openurl.split("?").last.presence
            SearchEngine::ResolverLink.new(url: "/openurl?#{u_params}")
          end
        end
      end

      def get_fulltext_links(xml)
        links = []

        if fulltext_url = xml.at_css("LINKS linktorsrc")&.text
          # try to get a label
          label = xml.at_css("links linktorsrc")&.text&.split("$$G")&.last
          # add link
          links << SearchEngine::Link.new(url: fulltext_url, label: label)
        end

        # Return links
        links
      end

      def get_subjects(xml)
        subjects = xml.css("search subject")&.map(&:text) || []
        subjects.map{|s| s.split(";").map(&:strip)}.flatten(1).map(&:presence).compact.uniq
      end

      def get_edition(xml)
        xml.at_css("display edition")&.text
      end

      def get_source(xml)
        if source = xml.at_css("display source")&.text
          SearchEngine::Relation.new(label: source)
        end
      end

      def get_languages(xml)
        languages = xml.css("display language")&.map(&:text) || []
        languages.map{|l| l.split(";").map(&:strip)}.flatten(1).map(&:presence).compact.uniq
      end

    end
  end
end
