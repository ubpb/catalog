module SearchEngine::Adapters
  class ElasticSearchAdapter
    class SearchOperation < PagedOperation

      def call(search_request, options = {})
        super # Call super to setup paged operation

        # Build up the search request for ES.
        es_request = {
          index: adapter.options[:index],
          body: {
            query: build_query(search_request),
            aggs: build_aggregations
          },
          from: (page - 1) * per_page,
          size: per_page
        }

        # Perform the search request against ES.
        es_result = adapter.client.search(es_request)
        puts JSON.pretty_generate(es_result)

        # Build the search result from ES result.
        build_search_result(es_result)
      end

    private

      def build_query(search_request)
        es_query = { bool: { must: [], must_not: [], should: [] } }

        # Build queries
        search_request.parts.each do |part|
          case part.query_type
          when "query"
            fields = adapter.searchables_fields(part.field)

            if fields.present?
              container = part.exclude == true ? es_query[:bool][:must_not] : es_query[:bool][:must]
              container << {
                simple_query_string: {
                  fields: fields,
                  query: normalize_query_string(part.value),
                  default_operator: "and"
                }
              }
            end
          when "aggregation"
            field = adapter.aggregations_field(part.field)
            type  = adapter.aggregations_type(part.field)

            if field && type
              container = part.exclude == true ? es_query[:bool][:must_not] : es_query[:bool][:must]

              case type
              when "term"
                container << {
                  term: {
                    field => part.value
                  }
                }
              end
            end
          end
        end

        # Ignore deleted records
        es_query[:bool][:must_not] << {
          term: { status: "D" }
        }

        es_query
      end

      def normalize_query_string(query_string)
        query_string = query_string.gsub(/\s(AND|UND)\s/, " + ")
        query_string = query_string.gsub(/\s(OR|ODER)\s/, " | ")
        query_string = query_string.gsub(/\s(NOT|NICHT)\s/, " -")

        query_string
      end

      def build_aggregations
        aggregations = {}

        adapter.aggregations.each do |aggregation|
          name  = aggregation["name"].presence
          field = aggregation["field"].presence
          type  = aggregation["type"].presence
          size  = aggregation["size"] || 20

          if name && field && type
            case type
            when "term"
              aggregations[name] = {
                terms: {
                  field: field,
                  size: size,
                  shard_size: 3 * size
                }
              }
            end
          end
        end

        aggregations
      end

      def build_search_result(es_result)
        total = es_result["hits"]["total"]

        hits = es_result["hits"]["hits"].map do |hit|
          SearchEngine::Hit.new(
            score: hit["_score"],
            record: RecordFactory.build(hit)
          )
        end

        aggregations = (es_result["aggregations"] || []).map do |name, aggregation|
          field = adapter.aggregations_field(name)
          type  = adapter.aggregations_type(name)

          if name && field && type
            case type
            when "term"
              terms = aggregation["buckets"].map do |bucket|
                SearchEngine::Aggregations::TermAggregation::Term.new(
                  term: bucket["key"],
                  count: bucket["doc_count"]
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
  end
end
