module SearchEngine::Adapters
  class ElasticSearchAdapter
    class SearchOperation < Operation

      def call(search_request, options = {})
        # Build up the search request for ES.
        es_request = {
          index: adapter.options[:index],
          body: {
            track_total_hits: true,
            query: build_query(search_request),
            aggs: build_aggregations,
            sort: build_sort(search_request)
          },
          from: search_request.page.from,
          size: search_request.page.size,
          preference: options[:session_id].presence || "_local"
        }

        # Perform the search request against ES.
        es_result = adapter.client.search(es_request)

        # TODO: Remove me
        # puts JSON.pretty_generate(es_request)
        # puts "--------"
        # puts JSON.pretty_generate(es_result.body)

        # Build the search result from ES result.
        build_search_result(es_result)
      rescue => e
        if e.message&.match?("parse_exception")
          raise SearchEngine::QuerySyntaxError, e
        else
          raise e
        end
      end

      private

      def build_query(search_request)
        es_query = {bool: {must: [], must_not: [], should: []}}

        # Queries
        search_request.queries.each do |q|
          fields = adapter.searchables_fields(q.name)

          if fields.present?
            container = q.exclude ? es_query[:bool][:must_not] : es_query[:bool][:must]

            # Build different queries depending on the field that is searched.
            # FIXME: This couples the implemenation to the config file, which is
            # very wrong and MUST be adressed.
            container << case q.name
            when "ids", "superorder_id"
              {
                multi_match: {
                  fields: fields,
                  type: "cross_fields",
                  query: q.value
                }
              }
            else
              {
                query_string: {
                  default_operator: "AND",
                  fields: fields,
                  type: "cross_fields",
                  query: normalize_query_string(q.value)
                  # quote_analyzer: "default_with_stop_words_search"
                }
              }
            end
          end
        end

        # Aggregations
        search_request.aggregations.each do |a|
          field = adapter.aggregations_field(a.name)
          type = adapter.aggregations_type(a.name)

          if field && type
            container = a.exclude ? es_query[:bool][:must_not] : es_query[:bool][:must]

            case type
            when "term"
              container << {
                term: {
                  field => a.value
                }
              }
            when "histogram"
              gte, lte = a.value.scan(/(\d{4})..(\d{4})/).flatten
              if gte && lte
                container << {
                  range: {
                    field => {
                      gte: gte,
                      lte: lte
                    }
                  }
                }
              end
            when "date_range"
              aggregation_config = adapter.aggregations.find { |ac| ac["name"] == a.name }
              next unless aggregation_config

              range_config = (aggregation_config["ranges"] || []).find { |r| r["key"] == a.value }
              next unless range_config

              # format_config = aggregation_config["format"].presence || "yyyy-MM-dd"

              range = {field => {}}
              range[field]["gte"] = gte if (gte = range_config["from"])
              range[field]["lte"] = lte if (lte = range_config["to"])

              if range.present?
                container << {
                  range: range
                }
              end
            end
          end
        end

        # Ignore deleted records
        es_query[:bool][:must_not] << {
          term: {"meta.is_deleted": true}
        }

        es_query
      end

      def normalize_query_string(query_string)
        # As we use a "Query string" query, we need to escape some
        # reserved characters, because we don't want to support
        # the full features "Query string" allows.
        # For now we just want to use boolean operators
        # and grouping. Therefore we need to escape some
        # reserved characters.
        #
        # See: https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-query-string-query.html#_boolean_operators
        # See: https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-query-string-query.html#_grouping

        # Escape characters function
        escape = ->(string) do
          # \ has to be escaped by itself AND has to be the first, to
          # avoid double escaping of other escape sequences
          #
          # See: https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-query-string-query.html#_reserved_characters
          # Not escaped:
          #   (, ) => to support grouping
          #   "    => to support phase search
          #   *, ? => to support wildcards
          #   ~    => to support fuzziness and proximity searches
          #
          %w(\\ + - = && || ! { } [ ] ^ : /).inject(string) do |s, c|
            # adapted from http://stackoverflow.com/questions/7074337/why-does-stringgsub-double-content
            s.gsub(c) { |match| "\\#{match}" } # avoid regular expression replacement string issues
          end
        end

        # Remove < and > from the query string to prevent range queries as they can't
        # be escaped.
        normalize_query_string = query_string.gsub(/<|>/, "")

        # Escape some special characters
        normalized_query_string = escape.call(normalize_query_string).presence || ""

        # Allow german bool operators (for compatability reasons)
        normalized_query_string = normalized_query_string
          .gsub("UND", "AND")
          .gsub("ODER", "OR")
          .gsub("NICHT", "NOT")

        # Replace german umlauts: This is somekind of a hack, in order to be able to use truncation (mütter*)
        # for words with german umlauts. This modification assumes that umlauts are stored
        # as ae, oe, ue representation in the index.
        normalized_query_string
          .gsub("Ä", "Ae").gsub("ä", "ae")
          .gsub("Ö", "Oe").gsub("ö", "oe")
          .gsub("Ü", "Ue").gsub("ü", "ue")
          .gsub("ß", "ss")
      end

      def build_aggregations
        aggregations = {}

        adapter.aggregations.each do |aggregation|
          name = aggregation["name"].presence
          field = aggregation["field"].presence
          type = aggregation["type"].presence
          size = aggregation["size"] || 20

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
            when "histogram"
              aggregations[name] = {
                histogram: {
                  field: field,
                  interval: 1,
                  min_doc_count: 1
                }
              }
            when "date_range"
              format = aggregation["format"].presence || "yyyy-MM-dd"
              ranges = (aggregation["ranges"].presence || []).map do |r|
                from = r["from"].presence
                to = r["to"].presence
                key = r["key"].presence

                range = {}
                range["from"] = from if from
                range["to"] = to if to
                range["key"] = key if key

                (from || to) ? range : nil
              end.compact

              if ranges.present?
                aggregations[name] = {
                  date_range: {
                    field: field,
                    format: format,
                    ranges: ranges
                  }
                }
              end
            end
          end
        end

        aggregations
      end

      def build_sort(search_request)
        sr_sort = search_request.sort
        es_sort = []

        if sr_sort.nil? || sr_sort.default?
          es_sort << "_score"
        else
          sort_field = adapter.sortables_field(sr_sort.name)
          direction = case sr_sort.direction
          when "asc" then "asc"
          when "desc" then "desc"
          else "asc"
          end

          es_sort << {sort_field => {"order" => direction}}
        end

        es_sort
      end

      def build_search_result(es_result)
        # Total hits
        total = es_result.dig("hits", "total", "value") || 0

        # Hits
        hits = es_result["hits"]["hits"].map do |hit|
          SearchEngine::Hit.new(
            score: hit["_score"],
            record: RecordFactory.build(hit)
          )
        end

        # Aggregations
        aggregations = (es_result["aggregations"] || []).map do |name, aggregation|
          field = adapter.aggregations_field(name)
          type = adapter.aggregations_type(name)

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
            when "histogram"
              values = aggregation["buckets"].sort_by { |a| a["key"] }.map do |bucket|
                SearchEngine::Aggregations::HistogramAggregation::Value.new(
                  key: bucket["key"].to_i,
                  count: bucket["doc_count"]
                )
              end

              SearchEngine::Aggregations::HistogramAggregation.new(
                name: name,
                field: field,
                values: values
              )
            when "date_range"
              ranges = aggregation["buckets"].map do |bucket|
                SearchEngine::Aggregations::DateRangeAggregation::Range.new(
                  key: bucket["key"],
                  count: bucket["doc_count"]
                  # TODO: implement from and to
                )
              end

              SearchEngine::Aggregations::DateRangeAggregation.new(
                name: name,
                field: field,
                ranges: ranges
              )
            end
          end
        end.compact

        # Sort aggregations as they are defined in the config file
        aggregations = aggregations.sort_by do |a|
          adapter.aggregations.find_index { |aa| aa["name"] == a.name } || 0
        end

        # Return result
        SearchEngine::SearchResult.new(
          hits: hits,
          aggregations: aggregations,
          total: total
        )
      end

    end
  end
end
