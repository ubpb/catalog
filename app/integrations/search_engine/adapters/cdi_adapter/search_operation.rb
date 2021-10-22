module SearchEngine::Adapters
  class CdiAdapter
    class SearchOperation < Operation

      def call(search_request, options = {})
        # Call CDI
        cdi_search = build_cdi_search(
          search_request,
          on_campus: options[:on_campus]
        )

        cdi_response = RestClient.post(
          adapter.options["api_base_url"],
          cdi_search, {
            "Content-Type" => "application/xml",
            "SOAPAction" => "searchBrief"
          }
        )

        cdi_result = parse_cdi_response(cdi_response)

        # Build the search result from CDI result.
        build_search_result(cdi_result)
      end

    private

      def parse_cdi_response(cdi_response)
        Nokogiri::XML(cdi_response.body)
          .remove_namespaces!
          .at_xpath("/Envelope/Body/searchBriefResponse/searchBriefReturn")
          .try(:text)
          .try do |sbr|
            Nokogiri::XML(sbr) { |config| config.noblanks }
              .remove_namespaces!
              .at_xpath("/SEGMENTS/JAGROOT/RESULT")
          end
      end

      def build_search_result(cdi_result)
        if docset = cdi_result.at_css("DOCSET")
          total = docset.attr("TOTALHITS").to_i

          hits = docset.css("DOC").map do |doc|
            SearchEngine::Hit.new(
              score: doc.attr("RANK").to_f,
              record: RecordFactory.build(doc)
            )
          end

          aggregations = (cdi_result.css("FACETLIST FACET") || []).map do |facet|
            name  = facet.attr("NAME")
            field = adapter.aggregations_field(name)
            type  = adapter.aggregations_type(name)

            if name && field && type
              case type
              when "term"
                terms = facet.css("FACET_VALUES").map do |facet_value|
                  SearchEngine::Aggregations::TermAggregation::Term.new(
                    term: facet_value.attr("KEY"),
                    count: facet_value.attr("VALUE").to_i
                  )
                end

                SearchEngine::Aggregations::TermAggregation.new(
                  name: name,
                  field: field,
                  terms: terms
                )
              end
            end
          end.compact

          SearchEngine::SearchResult.new(
            hits: hits,
            aggregations: aggregations,
            total: total
          )
        end
      end

      def clean_value(value)
        value
          .gsub("&", "")
          .gsub("<", "")
          .gsub(">", "")
      end

      def build_cdi_search(search_request, on_campus: false)
        institution = adapter.options["institution"] || "49PAD"

        start_index = search_request.page.from
        bulk_size   = search_request.page.size

        query_terms = []

        # Queries
        search_request.queries.each do |query|
          index_field = adapter.searchables_fields(query.name)&.first
          clean_value = clean_value(query.value)

          if query.exclude
            query_terms << <<-XML.strip_heredoc
              <QueryTerm>
                <IndexField>#{index_field}</IndexField>
                <PrecisionOperator>contains</PrecisionOperator>
                <Value/>
                <excludeValue>#{clean_value}</excludeValue>
              </QueryTerm>
            XML
          else
            query_terms << <<-XML.strip_heredoc
              <QueryTerm>
                <IndexField>#{index_field}</IndexField>
                <PrecisionOperator>contains</PrecisionOperator>
                <Value/>
                <includeValue>#{clean_value}</includeValue>
              </QueryTerm>
            XML
          end
        end

        # Aggregrations
        search_request.aggregations.each do |aggregation|
          index_field = adapter.aggregations_field(aggregation.name)
          clean_value = clean_value(aggregation.value)

          if aggregation.exclude
            query_terms << <<-XML.strip_heredoc
              <QueryTerm>
                <IndexField>#{index_field}</IndexField>
                <PrecisionOperator>exact</PrecisionOperator>
                <Value/>
                <excludeValue>#{clean_value}</excludeValue>
              </QueryTerm>
            XML
          else
            query_terms << <<-XML.strip_heredoc
              <QueryTerm>
                <IndexField>#{index_field}</IndexField>
                <PrecisionOperator>exact</PrecisionOperator>
                <Value/>
                <includeValue>#{clean_value}</includeValue>
              </QueryTerm>
            XML
          end
        end

        # Sort
        sort_field = adapter.sortables_field(search_request.sort.name)
        sort_field = "rank" unless sort_field

        <<-XML.strip_heredoc
        <env:Envelope xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:impl="http://primo.kobv.de/PrimoWebServices/services/searcher" xmlns:env="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ins0="http://xml.apache.org/xml-soap">
          <env:Body>
            <impl:searchBrief>
              <searchRequestStr>
                <![CDATA[
                  <searchRequest xmlns="http://www.exlibris.com/primo/xsd/wsRequest" xmlns:uic="http://www.exlibris.com/primo/xsd/primoview/uicomponents">
                    <PrimoSearchRequest xmlns="http://www.exlibris.com/primo/xsd/search/request">
                      <QueryTerms>
                        <BoolOpeator>AND</BoolOpeator>
                        #{query_terms.join("\n")}
                      </QueryTerms>
                      <StartIndex>#{start_index}</StartIndex>
                      <BulkSize>#{bulk_size}</BulkSize>
                      <DidUMeanEnabled>false</DidUMeanEnabled>
                      <HighlightingEnabled>false</HighlightingEnabled>
                      <Languages>
                        <Language>ger</Language>
                        <Language>eng</Language>
                      </Languages>
                      <SortByList>
                        <SortField>#{sort_field}</SortField>
                      </SortByList>
                      <Locations>
                        <uic:Location type="adaptor" value="primo_central_multiple_fe"/>
                      </Locations>
                    </PrimoSearchRequest>
                    <onCampus>#{on_campus == true}</onCampus>
                    <institution>#{institution}</institution>
                  </searchRequest>
                  ]]>
              </searchRequestStr>
            </impl:searchBrief>
          </env:Body>
        </env:Envelope>
        XML
      end

    end
  end
end
