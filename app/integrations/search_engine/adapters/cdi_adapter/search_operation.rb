module SearchEngine::Adapters
  class CdiAdapter
    class SearchOperation < PagedOperation

      def call(search_request, options = {})
        # Call super to setup paged operation
        super

        # Call CDI
        cdi_search = build_cdi_search(search_request)
        #puts cdi_search
        #puts "-------------------"

        cdi_response = RestClient.post(
          adapter.options["api_base_url"],
          cdi_search, {
            "Content-Type" => "application/xml",
            "SOAPAction" => "searchBrief"
          }
        )

        cdi_result = parse_cdi_response(cdi_response)
        #puts cdi_result.to_xml(ident: 2)

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
            total: total,
            page: page,
            per_page: per_page
          )
        end
      end

      def build_cdi_search(search_request)
        enable_cdi  = adapter.options["enable_cdi"]  || true
        institution = adapter.options["institution"] || "49PAD"
        on_campus   = true # TODO

        start_index = (page - 1) * per_page
        bulk_size   = per_page

        query_terms = []
        search_request.parts.each do |part|
          case part.query_type
          when "query"
            if part.exclude
              query_terms << <<-XML.strip_heredoc
                <QueryTerm>
                  <IndexField>#{part.field}</IndexField>
                  <PrecisionOperator>contains</PrecisionOperator>
                  <Value/>
                  <excludeValue>#{part.value}</excludeValue>
                </QueryTerm>
              XML
            else
              query_terms << <<-XML.strip_heredoc
                <QueryTerm>
                  <IndexField>#{part.field}</IndexField>
                  <PrecisionOperator>contains</PrecisionOperator>
                  <Value/>
                  <includeValue>#{part.value}</includeValue>
                </QueryTerm>
              XML
            end
          when "aggregation"
            index_field = adapter.aggregations_field(part.field)

            if part.exclude
              query_terms << <<-XML.strip_heredoc
                <QueryTerm>
                  <IndexField>#{index_field}</IndexField>
                  <PrecisionOperator>exact</PrecisionOperator>
                  <Value/>
                  <excludeValue>#{part.value}</excludeValue>
                </QueryTerm>
              XML
            else
              query_terms << <<-XML.strip_heredoc
                <QueryTerm>
                  <IndexField>#{index_field}</IndexField>
                  <PrecisionOperator>exact</PrecisionOperator>
                  <Value/>
                  <includeValue>#{part.value}</includeValue>
                </QueryTerm>
              XML
            end
          end
        end

        <<-XML.strip_heredoc
        <env:Envelope xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:impl="http://primo.kobv.de/PrimoWebServices/services/searcher" xmlns:env="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ins0="http://xml.apache.org/xml-soap">
          <env:Body>
            <impl:searchBrief>
              <searchRequestStr>
                <![CDATA[
                  <searchRequest xmlns="http://www.exlibris.com/primo/xsd/wsRequest" xmlns:uic="http://www.exlibris.com/primo/xsd/primoview/uicomponents">
                    <PrimoSearchRequest xmlns="http://www.exlibris.com/primo/xsd/search/request">
                      <RequestParams>
                        <RequestParam key="searchCDI">#{enable_cdi}</RequestParam>
                      </RequestParams>
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
                      <Locations>
                        <uic:Location type="adaptor" value="primo_central_multiple_fe"/>
                      </Locations>
                    </PrimoSearchRequest>
                    <onCampus>#{on_campus}</onCampus>
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
