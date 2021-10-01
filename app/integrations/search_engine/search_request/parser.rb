class SearchEngine
  class SearchRequest
    module Parser

      # Query example:
      #   ?sr[q,any]=linux    # query
      #   &sr[q,-title]=foo   # - => exclude
      #   &sr[a,rtype]=print  # aggregation
      #   &sr[s,title]=asc    # sort
      #   &sr[p]=2            # page
      def parse(url_or_query_string)
        queries      = []
        aggregations = []
        sort         = nil
        page         = nil
        options      = {}

        # Parse the url or query string.
        Addressable::URI
          .parse(url_or_query_string.include?("?") ? url_or_query_string : "?#{url_or_query_string}")
          .query_values(Array)
          .each do |key, value|
            case key
            # Syntax: sr[q,(-)FIELD]
            #   for two more optional parameter: /sr\[q,(-)?(\w+)(?:,(\w+))?(?:,(\w+))?\]/
            when /sr\[q,(-)?(\w+)\]/
              then queries << build_query($1, $2, value)
            # Syntax: sr[a,(-)FIELD]
            when /sr\[a,(-)?(\w+)\]/
              then aggregations << build_aggregation($1, $2, value)
            # Syntax: sr[s,FIELD]=DIRECTION
            when /sr\[s,(\w+)\]/
              then sort = build_sort($1, value)
            # Syntax: sr[p]=PAGE
            when /sr\[p\]/
              then page = build_page(value)
            # The rest...
            else
              options[key] = value
            end
          end

        SearchRequest.new(
          queries: queries,
          aggregations: aggregations,
          sort: sort,
          page: page,
          options: options
        )
      end

      alias_method :[], :parse

    private

      def build_query(exclude, field, value)
        if field
          Query.new(
            exclude: exclude.present?,
            field: field,
            value: value
          )
        end
      end

      def build_aggregation(exclude, field, value)
        if field
          Aggregation.new(
            exclude: exclude.present?,
            field: field,
            value: value
          )
        end
      end

      def build_sort(field, direction)
        if field
          Sort.new(field: field, direction: direction)
        end
      end

      def build_page(page)
        if page
          Page.new(page)
        end
      end

    end
  end
end
