module SearchEngine::Adapters
  class PrimoCentralAdapter
    class SearchOperation < Operation

      def call(search_request, options = {})
        from = search_request.options["from"]
        size = search_request.options["size"]

        on_campus = options[:on_campus] == true

        if search_request.is_a?(String)
          search_request = SearchEngine::SearchRequest[search_request]
        end

        pc_result = adapter.xclient.search(
          build_query(search_request),
          on_campus: on_campus,
          from: from + 1, # Primo uses a 1 based index. Our internal APIs assume a 0 based index.
          size: size
        )

        build_search_result(pc_result, from, size)
      end

    private

      # See: https://developers.exlibrisgroup.com/primo/apis/webservices/xservices/search/briefsearch
      def build_query(search_request)
        pc_query = {query: [], query_inc: [], query_exc: []}

        search_request.parts.each do |part|
          case part.query_type
          when "query"
            if field = normalize_field(part.field, adapter.options["searchable_fields"])
              container = pc_query[:query]
              container << "#{field},contains,#{normalize_value(part.value)}"
            end
          when "aggregation"
            if field = normalize_field(part.field, adapter.options["facets"])
              container = part.exclude ? pc_query[:query_exc] : pc_query[:query_inc]
              container << "#{field},exact,#{normalize_value(part.value)}"
            end
          end
        end

        pc_query
      end

      def normalize_field(field, lookup_table)
        norm_field = lookup_table.find{|e| e["name"] == field}.try(:[], "field").presence
        raise SearchEngine::SearchRequest::Error, "Unknown field '#{field}'" unless norm_field
        norm_field
      end

      def normalize_value(value)
        value.gsub(",", " ")
      end

      def build_search_result(pc_result, from, size)
        xml = Nokogiri::XML(pc_result).remove_namespaces!
        #puts xml.to_xml(indent: 2)

        total = xml.at_xpath(".//DOCSET")&.attr("TOTALHITS").to_i

        hits = xml.xpath(".//DOCSET/DOC")&.map do |hit|
          SearchEngine::Hit.new(
            score: hit.attr("RANK").to_f,
            record: RecordFactory.build(hit)
          )
        end || []

        SearchEngine::SearchResult.new(
          total: total,
          from: from,
          size: size,
          hits: hits
        )
      end

    end
  end
end
