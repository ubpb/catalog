module SearchEngine::Adapters
  class PrimoCentralAdapter
    class GetRecordOperation < Operation

      def call(record_id, options = {})
        on_campus = options[:on_campus] == true

        result = adapter.xclient.get_record(record_id, on_campus: on_campus)
        xml = Nokogiri::XML(result).remove_namespaces!

        if doc = xml.at_xpath(".//DOCSET/DOC")
          RecordFactory.build(doc)
        else
          adapter.logger.error("PrimoCentralAdapter::GetRecordOperation: No result for record ID `#{record_id}`.")
          nil
        end
      end

    end
  end
end
