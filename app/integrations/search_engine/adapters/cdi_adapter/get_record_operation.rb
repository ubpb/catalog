module SearchEngine::Adapters
  class CdiAdapter
    class GetRecordOperation < Operation

      def call(record_id, options = {})
        # Call CDI
        cdi_search = build_cdi_search(record_id)

        cdi_response = RestClient.post(
          adapter.options["api_base_url"],
          cdi_search, {
            "Content-Type" => "application/xml",
            "SOAPAction" => "searchBrief"
          }
        )

        cdi_result = parse_cdi_response(cdi_response)

        # Build the record from CDI result.
        build_record(cdi_result)
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

      def build_record(cdi_result)
        if doc = cdi_result.at_css("DOCSET > DOC")
          RecordFactory.build(doc)
        else
          nil
        end
      end

      def build_cdi_search(record_id)
        institution = adapter.options["institution"] || "49PAD"
        on_campus   = true # TODO

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
                        <QueryTerm>
                          <IndexField>rid</IndexField>
                          <PrecisionOperator>exact</PrecisionOperator>
                          <Value>#{record_id}</Value>
                        </QueryTerm>
                      </QueryTerms>
                      <StartIndex>0</StartIndex>
                      <BulkSize>1</BulkSize>
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
