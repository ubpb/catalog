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
      @queries.blank?
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

    # ----------------------------------------------------
    # Sort
    # ----------------------------------------------------

    private def sort=(sort)
      if sort
        @sort = sort
      else
        @sort = Sort.new # Default
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

    def validate!(search_scope:)
      orig    = self.dup
      adapter = SearchEngine[search_scope].adapter

      # Remove all queries with an empty value
      @queries = @queries.reject do |q|
        q.value.blank?
      end

      # Make sure queries are unique
      @queries = @queries.uniq

      # Remove all queries with unknown names
      @queries = @queries.reject do |q|
        !adapter.searchables_names.include?(q.name)
      end

      # Remove all aggregations with an empty value
      @aggregations = @aggregations.reject do |a|
        a.value.blank?
      end

      # Make sure aggregations are unique
      @aggregations = @aggregations.uniq

      # Remove all aggregations with unknown names
      @aggregations = @aggregations.reject do |a|
        !adapter.aggregations_names.include?(a.name)
      end

      # Remove sort for unknown name
      # FIXME
      #if @sort && !adapter.sortables_names.include?(@sort.name)
      #  @sort = nil
      #end

      # Run validation checks ...
      if @queries.count != orig.queries.count ||
        @aggregations.count != orig.aggregations.count ||
        @sort != orig.sort ||
        empty?
        false
      else
        true
      end
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
        #elsif @sort.default_direction?
        #  sort << "sr[s]=#{@sort.name}"
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
