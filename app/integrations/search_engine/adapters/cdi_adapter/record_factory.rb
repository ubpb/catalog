module SearchEngine::Adapters
  class CdiAdapter
    class RecordFactory

      def self.build(xml)
        self.new.build(xml)
      end

      #
      # xml =>
      #   <DOC NO="1" SEARCH_ENGINE="primo_central_multiple_fe" SEARCH_ENGINE_TYPE="Primo Central Search Engine" RANK="2.4719088" LOCAL="false">
      #     <PrimoNMBib>
      #       <record>...</record>
      #     <PrimoNMBib>
      #     <LINKS>...</LINKS>
      #   </DOC>
      #
      def build(xml)
        xxx = SearchEngine::Record.new(
          id: get_id(xml),
          title: get_title(xml),
          creators: get_creators(xml),
          year_of_publication: get_year_of_publication(xml),
          publication_notices: get_publishers(xml),
          edition: get_edition(xml),
          languages: get_languages(xml),
          additional_identifiers: get_identifiers(xml),
          subjects: get_subjects(xml),
          notes: get_descriptions(xml),
          is_part_of: get_is_part_of(xml),
          source: get_source(xml),
          resolver_link: get_resolver_link(xml),
          fulltext_links: get_fulltext_links(xml)
        )

        #binding.b

        puts xml
        puts "-------------------------"
        pp xxx

        xxx
      end

    private

      def get_id(xml)
        xml.at_xpath("//control/recordid")&.text&.gsub(/\ATN_/, "")
      end

      def get_title(xml)
        xml.at_xpath("//display/title")&.text || "n.a."
      end

      def get_creators(xml)
        names = []
        names += xml.xpath("//display/creator")&.map(&:text) || []
        names += xml.xpath("//display/contributor")&.map(&:text) || []

        names.map do |n|
          n.split(";").map(&:strip)
        end
        .flatten(1)
        .map(&:presence)
        .compact
        .uniq
        .map do |n|
          SearchEngine::Creator.new(name: n)
        end
      end

      def get_year_of_publication(xml)
        xml.at_xpath("//display/creationdate")&.text ||
        xml.at_xpath("//search/creationdate")&.text
      end

      def get_publishers(xml)
        publishers = xml.xpath("//display/publisher")&.map(&:text) || []
        publishers.map{|p| p.split(";").map(&:strip)}.flatten(1).map(&:presence).compact.uniq
      end

      def get_edition(xml)
        xml.xpath("//display/edition")&.text
      end

      def get_languages(xml)
        languages = xml.xpath("//display/language")&.map(&:text) || []
        languages.map{|l| l.split(";").map(&:strip)}.flatten(1).map(&:presence).compact.uniq
      end

      def get_identifiers(xml)
        identifiers = []

        xml.xpath("//addata/isbn")&.each do |i|
          identifiers << SearchEngine::Identifier.new(type: :isbn, value: i.text)
        end

        xml.xpath("//addata/issn")&.each do |i|
          identifiers << SearchEngine::Identifier.new(type: :issn, value: i.text)
        end

        xml.xpath("//addata/eissn")&.each do |i|
          identifiers << SearchEngine::Identifier.new(type: :eissn, value: i.text)
        end

        xml.xpath("//addata/doi")&.each do |i|
          identifiers << SearchEngine::Identifier.new(type: :doi, value: i.text)
        end

        identifiers
      end

      def get_subjects(xml)
        subjects = xml.xpath("//search/subject")&.map(&:text) || []
        subjects.map{|s| s.split(";").map(&:strip)}.flatten(1).map(&:presence).compact.uniq
      end

      def get_descriptions(xml)
        xml.xpath("//display/description")&.map(&:text)
      end

      def get_is_part_of(xml)
        xml.xpath("//display/ispartof")&.map(&:text)&.map do |label|
          SearchEngine::IsPartOf.new(label: label)
        end
      end

      def get_source(xml)
        if source = xml.at_xpath("//display/source")&.text
          SearchEngine::Relation.new(label: source)
        end
      end

      def get_resolver_link(xml)
        if openurl = xml.at_xpath("//LINKS/openurl")&.text
          if u_params = openurl.split("?").last.presence
            SearchEngine::ResolverLink.new(url: "/openurl?#{u_params}")
          end
        end
      end

      def get_fulltext_links(xml)
        links = []

        # Check //record/links/linktorsrc
        if link_to_rsrc = get_link_elements(xml, xpath: "//record/links/linktorsrc")
          if url = link_to_rsrc["U"]
            links << SearchEngine::Link.new(
              url: url,
              label: link_to_rsrc["G"]
            )
          end
        end

        # Check for //record/links/linktopdf
        if link_to_pdf = get_link_elements(xml, xpath: "//record/links/linktopdf")
          if url = link_to_pdf["U"]
            links << SearchEngine::Link.new(url: url)
          end
        end

        # Check for //record/links/linktohtml
        if link_to_pdf = get_link_elements(xml, xpath: "//record/links/linktohtml")
          if url = link_to_pdf["U"]
            links << SearchEngine::Link.new(url: url)
          end
        end

        # Return links
        links
      end

      def get_link_elements(xml, xpath:)
        xml.at_xpath(xpath)
          &.text
          &.split("$$")
          &.map(&:presence)
          &.compact
          &.inject({}){|memo, s| memo[s[0]] = s[1..-1]; memo}
      end

    end
  end
end
