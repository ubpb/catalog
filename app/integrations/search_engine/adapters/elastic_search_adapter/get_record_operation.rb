module SearchEngine::Adapters
  class ElasticSearchAdapter
    class GetRecordOperation < Operation

      def call(record_id, options = {})
        result = adapter.client.get(index: adapter.options[:index], id: record_id)

        marked_as_deleted = result["_source"].dig("meta", "is_deleted") == true

        unless marked_as_deleted
          RecordFactory.build(result)
        else
          nil
        end
      rescue Elastic::Transport::Transport::Errors::NotFound
        nil
      end

    end
  end
end
