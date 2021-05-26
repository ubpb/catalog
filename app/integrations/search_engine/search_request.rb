class SearchEngine
  class SearchRequest

    class Error < SearchEngine::Error ; end
    class SyntaxError < Error ; end

    class RequestPart < BaseStruct
      QueryTypes = Types::String.enum("query", "aggregation")

      attribute :query_type, QueryTypes
      attribute :field, Types::String
      attribute :value, Types::String
      attribute :exclude, Types::Bool.default(false)
    end

    class << self
      # q[any]=foo&q[title,contains]=bar&q[-title,exact]=baz&page=2&some_option=option_value
      def [](query_string)
        parts   = []
        options = {}

        # Parse the query string.
        query_values = Addressable::URI.parse("?#{query_string}").query_values(Array)
        query_values.each do |key, value|
          case key
          when /\Aq/ then parse_query(key, value, parts)
          when /\Aa/ then parse_aggregation(key, value, parts)
          else parse_option(key, value, options)
          end
        end

        SearchRequest.new(parts, options)
      end

      alias_method :parse, :[]

    private

      # q[(-)FIELD(,PRECISION(,OPERATOR))]=VALUE
      def parse_query(key, value, parts)
        exclude, field, precision, operator = key.match(
          /q\[(-)?(\w+)(?:,(\w+))?(?:,(\w+))?\]/
        ).try(:[], 1..-1)

        if field.present?
          # TODO: Add precision and operator
          parts << RequestPart.new(
            query_type: "query",
            exclude: exclude.present?,
            field: field,
            value: value
          )
        else
          raise SyntaxError, "Invalid query syntax."
        end
      end

      def parse_aggregation(key, value, parts)
        # TODO
      end

      def parse_option(key, value, options)
        options[key] = value
      end
    end

    attr_reader :options
    attr_reader :parts

    def initialize(parts, options = {})
      @parts   = parts
      @options = options
    end

    def empty?
      parts.blank?
    end

    def validate!(search_scope)
      changed = false
      validated_parts = @parts.dup

      # Remove all parts with an empty value
      validated_parts = validated_parts.reject{|p| p.value.blank?}
      # Remove all queries with unknown fields
      validated_parts = validated_parts.reject{|p| p.query_type == "query" && !searchable_fields(search_scope).include?(p.field)}
      # Remove all aggregations with unknown fields
      # TODO

      # Check if something has changed
      unless (@parts - validated_parts).empty?
        changed = true
        @parts = validated_parts
      end

      !changed
    end

    def query_string
      param_hash = {}

      @parts.each do |part|
        query_type = case part.query_type
          when "query"       then "q"
          when "aggregation" then "a"
        end

        if query_type
          field = part.field
          field = "-#{field}" if part.exclude
          value = Addressable::URI.encode_component(part.value, Addressable::URI::CharacterClasses::UNRESERVED)

          param_hash[query_type]        ||= {}
          param_hash[query_type][field] ||= []
          param_hash[query_type][field] << value
        end
      end

      param_hash.each_value do |v|
        v.map do |k, fv|
          if fv.length == 1
            v[k] = fv.first
          else
            v[k] = fv
          end
        end
      end

      Addressable::URI.unencode_component(param_hash.to_param)
    end

  private

    def searchable_fields(search_scope)
      @_searchable_fields ||= SearchEngine[search_scope]
        .options
        .try(:[], "searchable_fields")
        &.map{|_| _["name"]} || []
    end

  end
end
