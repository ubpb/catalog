module SearchEngine::Adapters
  class PrimoCentralAdapter
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
          part_of: get_part_of(xml),
          publishers: get_publishers(xml),
          identifiers: get_identifiers(xml),
          descriptions: get_descriptions(xml),
          resource_links: get_resource_links(xml),
          subjects: get_subjects(xml),
          edition: get_edition(xml),
          source: get_source(xml),
          languages: get_languages(xml)
        )
      end

    private

      def get_id(xml)
        id = xml.at_xpath(".//control/recordid")&.text
        # Record IDs returning from Primo Central will hold a leading "TN_" infront of them.
        # In order to query against such record IDs, we must remove the leading TN_
        id.gsub(/\ATN_/, '')
      end

      def get_title(xml)
        xml.at_xpath(".//display/title")&.text
      end

      def get_year_of_publication(xml)
        xml.at_xpath(".//display/creationdate")&.text
      end

      def get_creators_and_contributors(xml)
        cc = []

        xml.xpath(".//addata/au").each do |cc_node|
          cc << cc_node.text.presence
        end

        cc.compact.uniq
      end

      def get_publishers(xml)
        if publisher = xml.at_xpath(".//display/publisher")&.text
          [publisher]
        end
      end

      def get_part_of(xml)
        if part_of = xml.at_xpath(".//display/ispartof")&.text
          [SearchEngine::Relation.new(label: part_of)]
        end
      end

      def get_identifiers(xml)
        identifiers = []

        if issn = xml.at_xpath(".//addata/issn")&.text
          identifiers << SearchEngine::Identifier.new(type: :issn, value: issn)
        end

        if eissn = xml.at_xpath(".//addata/eissn")&.text
          identifiers << SearchEngine::Identifier.new(type: :eissn, value: eissn)
        end

        if doi = xml.at_xpath(".//addata/doi")&.text
          identifiers << SearchEngine::Identifier.new(type: :doi, value: doi)
        end

        identifiers
      end

      def get_descriptions(xml)
        if description = xml.at_xpath(".//addata/abstract")&.text
          [description]
        end
      end

      def get_resource_links(xml)
        links = []

        if openurl = xml.at_xpath(".//LINKS/openurl")&.text
          # Remove the language param to force the default language
          openurl = openurl.split('&').map{|e| e.gsub(/req\.language=.+/, 'req.language=')}.join('&')
          # See: https://github.com/ubpb/issues/issues/59
          openurl = openurl.gsub(/primo3-Article/i, "primo3-article")

          links << SearchEngine::Link.new(url: openurl)
        end

        links
      end

      def get_subjects(xml)
        subjects = []

        xml.xpath(".//search/subject").each do |subject_node|
          subjects << subject_node.text.presence
        end

        subjects.compact.uniq
      end

      def get_edition(xml)
        xml.at_xpath(".//display/edition")&.text
      end

      def get_source(xml)
        if source = xml.at_xpath(".//display/source")&.text
          SearchEngine::Relation.new(label: source)
        end
      end

      def get_languages(xml)
        if language_text = xml.at_xpath(".//display/language")&.text
          language_text.split(";").map(&:presence).compact.uniq
        end
      end

    end
  end
end
