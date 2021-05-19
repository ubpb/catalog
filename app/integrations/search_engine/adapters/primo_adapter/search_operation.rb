module SearchEngine::Adapters
  class PrimoAdapter
    class SearchOperation < PagedOperation

      def call(search_request, options = {})
        # Call super to setup paged operation
        super

        # Set onCampus
        # TODO: There is no flag in REST API

        # Build primo search queries
        q_param = build_q_param(search_request)

        # Perform search request
        json_result = adapter.api.get("search", params: {
          vid: "49HBZPAD_V1",
          tab: "default_tab",
          scope: "default_scope",
          q: q_param,
          lang: "en",
          offset: (page - 1) * per_page,
          limit: per_page,
          sort: "rank",
          pcAvailability: "true",
          getMore: "0",
          conVoc: "true",
          #inst: "49PAD",
          skipDelivery: "true",
          disableSplitFacets: "true",
          searchCDI: "true"
        })

        # Parse result
        build_search_result(json_result)
      end

    private

      def build_q_param(search_request)
        qs = []

        search_request.parts.each do |part|
          value = part.value.gsub(";", " ")
          qs << "#{part.field},contains,#{value}"
        end

        qs.join(";")
      end

      def build_search_result(json_result)
        total = json_result.dig("info", "total") || 0

        hits = json_result["docs"]&.map do |doc|
          SearchEngine::Hit.new(
            score: 0.0, # The Primo REST API does not provide rank or score info
            record: RecordFactory.build(doc)
          )
        end || []

        SearchEngine::SearchResult.new(
          hits: hits,
          total: total,
          page: page,
          per_page: per_page
        )
      end

      # -----------------------------

      # # See: https://developers.exlibrisgroup.com/primo/apis/webservices/xservices/search/briefsearch
      # def build_query(search_request)
      #   pc_query = {query: [], query_inc: [], query_exc: []}

      #   search_request.parts.each do |part|
      #     case part.query_type
      #     when "query"
      #       if field = normalize_field(part.field, adapter.options["searchable_fields"])
      #         container = pc_query[:query]
      #         container << "#{field},contains,#{normalize_value(part.value)}"
      #       end
      #     when "aggregation"
      #       if field = normalize_field(part.field, adapter.options["facets"])
      #         container = part.exclude ? pc_query[:query_exc] : pc_query[:query_inc]
      #         container << "#{field},exact,#{normalize_value(part.value)}"
      #       end
      #     end
      #   end

      #   pc_query
      # end

      # def normalize_field(field, lookup_table)
      #   norm_field = lookup_table.find{|e| e["name"] == field}.try(:[], "field").presence
      #   raise SearchEngine::SearchRequest::Error, "Unknown field '#{field}'" unless norm_field
      #   norm_field
      # end

      # def normalize_value(value)
      #   value.gsub(",", " ")
      # end

      # def build_search_result(pc_result, from, size)
      #   xml = Nokogiri::XML(pc_result).remove_namespaces!
      #   #puts xml.to_xml(indent: 2)

      #   total = xml.at_xpath(".//DOCSET")&.attr("TOTALHITS").to_i

      #   hits = xml.xpath(".//DOCSET/DOC")&.map do |hit|
      #     SearchEngine::Hit.new(
      #       score: hit.attr("RANK").to_f,
      #       record: RecordFactory.build(hit)
      #     )
      #   end || []

      #   SearchEngine::SearchResult.new(
      #     total: total,
      #     from: from,
      #     size: size,
      #     hits: hits
      #   )
      # end

    end
  end
end
