module SearchEngine::Adapters
  class ElasticSearchAdapter
    class GetRecordOperation < Operation

      def call(record_id, options = {})
        if (other_id = options[:by_other_id]).present?
          get_record_by_other_id(field: other_id, id: record_id)
        else
          get_record_by_mms_id(record_id)
        end
      end

    private

      def get_record_by_mms_id(record_id)
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

      def get_record_by_other_id(field:, id:)
        request = {
          index: adapter.options[:index],
          body: {
            query: {
              term: {"#{field}": id}
            }
          }
        }

        result = adapter.client.search(request)
        if first_hit = result["hits"]["hits"][0]
          unless first_hit["_source"].dig("meta", "is_deleted") == true
            RecordFactory.build(first_hit)
          else
            nil
          end
        else
          nil
        end
      end
    end
  end
end
