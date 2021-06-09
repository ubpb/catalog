module SearchEngine::Adapters
  class ElasticSearchAdapter
    class SearchOperation < PagedOperation

      def call(search_request, options = {})
        # Call super to setup paged operation
        super

        es_result = adapter.client.search(
          index: adapter.options[:index],
          body: {
            query: build_query(search_request),
            aggregations: build_aggregations
          },
          from: (page - 1) * per_page,
          size: per_page
        )

        puts JSON.pretty_generate(es_result)

        build_search_result(es_result)
      end

    private

      def build_query(search_request)
        es_query = { bool: { must: [], must_not: [], should: [] } }

        # Build queries
        search_request.parts.each do |part|
          case part.query_type
          when "query"
            fields = get_query_fields(part.field)

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
            field = get_aggregation_field(part.field)
            type  = get_aggregation_type(part.field)

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

      def get_query_fields(field_name)
        #default_fields    = adapter.options["default_fields"]    || ["_all"]
        searchable_fields = adapter.options["searchable_fields"] || []

        field  = searchable_fields.find{|e| e["name"] == field_name}.try(:[], "field").presence
        fields = searchable_fields.find{|e| e["name"] == field_name}.try(:[], "fields").presence

        #binding.pry
        query_fields =  field ? [field] : fields # || default_fields)
        raise SearchEngine::SearchRequest::Error if query_fields.blank?
        query_fields
      end

      def get_aggregation_field(field_name)
        aggregations = adapter.options["aggregations"] || []
        aggregations.find{|e| e["name"] == field_name}.try(:[], "field").presence
      end

      def get_aggregation_type(field_name)
        aggregations = adapter.options["aggregations"] || []
        aggregations.find{|e| e["name"] == field_name}.try(:[], "type").presence
      end

      def build_search_result(es_result)
        total = es_result["hits"]["total"]

        hits = es_result["hits"]["hits"].map do |hit|
          SearchEngine::Hit.new(
            score: hit["_score"],
            record: RecordFactory.build(hit)
          )
        end

        facets = es_result["aggregations"].map do |name, aggregation|
          field   = get_aggregation_field(name)
          type    = get_aggregation_type(name)

          if name && field && type
            case type
            when "term"
              terms = aggregation["buckets"].map do |bucket|
                SearchEngine::Facets::TermFacet::Term.new(
                  term: bucket["key"],
                  count: bucket["doc_count"]
                )
              end

              SearchEngine::Facets::TermFacet.new(
                name: name,
                field: field,
                terms: terms
              )
            end
          end
        end.compact

        SearchEngine::SearchResult.new(
          hits: hits,
          facets: facets,
          total: total,
          page: page,
          per_page: per_page
        )
      end

      def build_aggregations
        aggregations = {}

        adapter.options[:aggregations]&.each do |aggregation|
          name  = aggregation["name"].presence
          field = aggregation["field"].presence
          size  = aggregation["size"] || 10
          type  = aggregation["type"]

          if name && field && size && type
            case type
            when "term"
              aggregations[name] = {
                terms: {
                  field: field,
                  missing: "N/A",
                  size: size,
                  shard_size: 3 * size
                }
              }
            end
          end
        end

        aggregations
      end

    end
  end
end
