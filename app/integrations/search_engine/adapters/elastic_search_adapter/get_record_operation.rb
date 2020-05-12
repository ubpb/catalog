module SearchEngine::Adapters
  class ElasticSearchAdapter
    class GetRecordOperation < Operation

      def call(record_id, options = {})
        result = adapter.client.get(index: adapter.options[:index], type: "_all", id: record_id)
        #pp result
        marked_as_deleted = result["_source"]["status"] == "D"

        unless marked_as_deleted
          RecordFactory.build(result)
        else
          nil
        end
      rescue Elasticsearch::Transport::Transport::Errors::NotFound
        nil
      end

    end
  end
end
