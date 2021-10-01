module SearchEngine::Adapters
  class ElasticSearchAdapter
    class SearchOperation < Operation

      def call(search_request, options = {})
        # Build up the search request for ES.
        es_request = {
          index: adapter.options[:index],
          body: {
            query: build_query(search_request),
            aggs: build_aggregations,
            sort: ["_score"]
          },
          from: search_request.page.from,
          size: search_request.page.size,
          preference: "_primary_first"
        }

        # Perform the search request against ES.
        es_result = adapter.client.search(es_request)
        #puts JSON.pretty_generate(es_result)

        # Build the search result from ES result.
        build_search_result(es_result)
      end

    private

      def build_query(search_request)
        es_query = { bool: { must: [], must_not: [], should: [] } }

        # Queries
        search_request.queries.each do |q|
          fields = adapter.searchables_fields(q.field)
          query  = normalize_query_string(q.value)

          if fields.present?
            container = q.exclude ? es_query[:bool][:must_not] : es_query[:bool][:must]
            container << {
              query_string: {
                default_operator: "AND",
                fields:           fields,
                query:            query,
                quote_analyzer:   "default_with_stop_words_search"
              }
            }

            # Use a "should" component that uses stop words for better ranking
            container = es_query[:bool][:should]
            container << {
              query_string: {
                default_operator: "AND",
                fields:           fields,
                query:            query,
                quote_analyzer:   "default_with_stop_words_search",
                analyzer:         "default_with_stop_words_search"
              }
            }
          end
        end

        # Aggregations
        search_request.aggregations.each do |a|
          field = adapter.aggregations_field(a.field)
          type  = adapter.aggregations_type(a.field)

          if field && type
            container = a.exclude ? es_query[:bool][:must_not] : es_query[:bool][:must]

            case type
            when "term"
              container << {
                term: {
                  field => a.value
                }
              }
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
          total: total
        )
      end

    end
  end
end
