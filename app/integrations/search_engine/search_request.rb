class SearchEngine
  class SearchRequest

    class Error < RuntimeError ; end

    class RequestPart < BaseStruct
      QueryTypes = Types::String.enum("query", "aggregation")

      attribute :query_type, QueryTypes
      attribute :field, Types::String
      attribute :value, Types::String
      attribute :exclude, Types::Bool.default(false)
    end

    class << self
      # Hash: {"q"=>{"*"=>"foo", "title"=>["bar", "baz"], "-title"=>"xxx"}, "a"=>{"notation"=>"foo"}}
      def [](params)
        parts   = []
        options = {}

        if params.is_a?(Hash)
          params.each do |query_type_key, query_type_params|
            query_type = case query_type_key
              when "q" then "query"
              when "a" then "aggregation"
              else "query"
            end

            if query_type_params.is_a?(Hash)
              query_type_params.each do |k, v|
                exclude = k.starts_with?("-")
                field   = exclude ? k[1..-1] : k
                values  = [*v]

                values.each do |value|
                  parts << RequestPart.new(
                    query_type: query_type,
                    exclude: exclude,
                    field: field,
                    value: value
                  )
                end
              end
            end
          end
        end

        SearchRequest.new(parts)
      end

      alias_method :parse, :[]
    end


    DEFAULT_OPTIONS = {
      "from" => 0,
      "size" => 10
    }.freeze

    attr_reader :options
    attr_reader :parts

    def initialize(parts, options = {})
      @parts   = parts
      @options = sanitize_options(options)
    end

    def to_h
      param_hash = {}

      @parts.each do |part|
        query_type = case part.query_type
          when "query" then "q"
          when "aggregation" then "a"
          else "q"
        end
        field = part.field
        field = "-#{field}" if part.exclude
        value = Addressable::URI.encode_component(part.value, Addressable::URI::CharacterClasses::UNRESERVED)

        param_hash[query_type]        ||= {}
        param_hash[query_type][field] ||= []
        param_hash[query_type][field] << value
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

      param_hash
    end

    def to_param
      Addressable::URI.unencode_component(to_h.to_param)
    end

  private

    def sanitize_options(options)
      s_options = DEFAULT_OPTIONS.merge(options)

      s_options["from"] = options["from"].to_i
      s_options["from"] = 0 if s_options["from"] <= 0

      s_options["size"] = options["size"].to_i
      s_options["size"] = 10 if s_options["size"] <= 0
      s_options["size"] = 50 if s_options["size"] > 50

      s_options.with_indifferent_access
    end

  end
end
