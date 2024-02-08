module SearchEngine::Adapters
  class ElasticSearchAdapter
    class GetRecordOperation < Operation

      # TODO: We should streamline this without
      # diffrent options.
      def call(record_id, options = {})
        if (other_id = options[:by_other_id]).present?
          get_record_by_other_id(field: other_id, id: record_id)
        elsif (options[:by_additional_ids] == true)
          get_record_by_additional_ids(record_id)
        else
          get_record_by_mms_id(record_id)
        end
      end

      private

      def get_record_by_mms_id(record_id)
        result = adapter.client.get(index: adapter.options[:index], id: record_id)

        marked_as_deleted = result["_source"].dig("meta", "is_deleted") == true

        RecordFactory.build(result) unless marked_as_deleted
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

        record = result["hits"]["hits"].find do |r|
          r["_source"].dig("meta", "is_deleted") == false
        end

        RecordFactory.build(record) if record
      end

      # FIXME: This couples the implemenation to the config file, which is
      # very wrong and MUST be adressed.
      def get_record_by_additional_ids(record_id)
        request = {
          index: adapter.options[:index],
          body: {
            query: {
              match: {
                additional_identifiers: {
                  query: record_id
                }
              }
            }
          }
        }

        result = adapter.client.search(request)

        record = result["hits"]["hits"].find do |r|
          r["_source"].dig("meta", "is_deleted") == false
        end

        RecordFactory.build(record) if record
      end

    end
  end
end
