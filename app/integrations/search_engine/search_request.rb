class SearchEngine
  class SearchRequest
    extend Parser

    def initialize(queries: [], aggregations: [], sort: nil, page: nil, options: {})
      self.queries = queries
      self.aggregations = aggregations
      self.sort = sort
      self.page = page
      self.options = options
    end

    def initialize_copy(orig)
      super
      self.queries = orig.queries.deep_dup
      self.aggregations = orig.aggregations.deep_dup
      self.sort = orig.sort.dup
      self.page = orig.page.dup
      self.options = orig.options.deep_dup
    end

    # ----------------------------------------------------
    # Utils
    # ----------------------------------------------------

    def empty?
      self.queries.blank?
    end

    def ==(other)
      self.queries      == other&.queries &&
      self.aggregations == other&.aggregations &&
      self.sort         == other&.sort &&
      self.page         == other&.page &&
      self.options      == other&.options
    end

    def eql?(other)
      self == other
    end

    # ----------------------------------------------------
    # Queries
    # ----------------------------------------------------

    private def queries=(queries)
      @queries = queries || []
    end

    attr_reader :queries

    def find_query(name, value)
      @queries.find{|q| q.name == name && q.value == value}
    end

    def has_query?(name, value)
      find_query(name, value).present?
    end

    def add_query(query)
      @queries << query
      self
    end

    def delete_query(name, value)
      @queries = @queries.reject do |q|
        q.name == name && q.value == value
      end

      self
    end

    # ----------------------------------------------------
    # Aggregations
    # ----------------------------------------------------

    private def aggregations=(aggregations)
      @aggregations = aggregations || []
    end

    attr_reader :aggregations

    def find_aggregation(name, value)
      @aggregations.find{|a| a.name == name && a.value == value}
    end

    def has_aggregation?(name, value)
      find_aggregation(name, value).present?
    end

    def add_aggregation(aggregation)
      @aggregations << aggregation
      self
    end

    def delete_aggregation(name, value)
      @aggregations = @aggregations.reject do |a|
        a.name == name && a.value == value
      end

      self
    end

    def delete_all_aggregations(name)
      @aggregations = @aggregations.reject do |a|
        a.name == name
      end

      self
    end

    # ----------------------------------------------------
    # Sort
    # ----------------------------------------------------

    private def sort=(sort)
      if sort
        @sort = sort
      else
        @sort = Sort.default
      end
    end

    attr_reader :sort

    def set_sort(sort)
      self.sort = sort
      self
    end

    # ----------------------------------------------------
    # Page
    # ----------------------------------------------------

    private def page=(value)
      @page = value || Page.new
    end

    attr_reader :page

    def reset_page
      @page = Page.new
      self
    end

    # ----------------------------------------------------
    # Options
    # ----------------------------------------------------

    def options=(value)
      @options = value&.with_indifferent_access || {}
    end

    attr_reader :options

    #
    # Validation
    #

    def validate!(adapter)
      validated_queries      = self.queries.map{|q| q.validate!(adapter)}.compact
      validated_aggregations = self.aggregations.map{|a| a.validate!(adapter)}.compact
      validated_sort         = self.sort.validate!(adapter)
      validated_page         = self.page.validate!(adapter)

      vsr = SearchRequest.new(
        queries: validated_queries,
        aggregations: validated_aggregations,
        sort: validated_sort,
        page: validated_page,
        options: self.options
      )

      return vsr.empty? ? nil : vsr
    end

    # ----------------------------------------------------
    # Query string
    # ----------------------------------------------------

    def query_string
      queries = @queries.map do |q|
        name = q.name
        name = "-#{name}" if q.exclude
        value = Addressable::URI.encode_component(q.value, Addressable::URI::CharacterClasses::UNRESERVED)
        "sr[q,#{name}]=#{value}"
      end

      aggregations = @aggregations.map do |a|
        name = a.name
        name = "-#{name}" if a.exclude
        value = Addressable::URI.encode_component(a.value, Addressable::URI::CharacterClasses::UNRESERVED)
        "sr[a,#{name}]=#{value}"
      end

      sort = []
      if @sort
        if @sort.default?
          sort = []
        elsif @sort.direction.nil?
          sort << "sr[s]=#{@sort.name}"
        else
          sort << "sr[s,#{@sort.direction}]=#{@sort.name}"
        end
      end

      page = []
      unless @page.first_page?
        page << "sr[p]=#{@page.page}"
      end

      options = @options.map do |k,v|
        value = Addressable::URI.encode_component(v, Addressable::URI::CharacterClasses::UNRESERVED)
        "#{k}=#{value}"
      end

      (queries + aggregations + sort + page + options).join("&")
    end

    alias_method :to_s, :query_string

  end
end
