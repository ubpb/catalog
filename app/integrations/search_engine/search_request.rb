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

    private def queries=(value)
      @queries = value || []
    end

    attr_reader :queries

    def find_query(field, value)
      @queries.find{|q| q.field == field && q.value == value}
    end

    def has_query?(field, value)
      find_query(field, value).present?
    end

    def add_query(query)
      @queries << query
      self
    end

    def delete_query(field, value)
      @queries = @queries.reject do |q|
        q.field == field && q.value == value
      end

      self
    end

    # ----------------------------------------------------
    # Aggregations
    # ----------------------------------------------------

    private def aggregations=(value)
      @aggregations = value || []
    end

    attr_reader :aggregations

    def find_aggregation(field, value)
      @aggregations.find{|a| a.field == field && a.value == value}
    end

    def has_aggregation?(field, value)
      find_aggregation(field, value).present?
    end

    def add_aggregation(aggregation)
      @aggregations << aggregation
      self
    end

    def delete_aggregation(field, value)
      @aggregations = @aggregations.reject do |a|
        a.field == field && a.value == value
      end

      self
    end

    # ----------------------------------------------------
    # Sort
    # ----------------------------------------------------

    private def sort=(value)
      @sort = value
    end

    attr_reader :sort

    def sorted?
      @sort.present?
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

      # Remove all queries with unknown fields
      @queries = @queries.reject do |q|
        !adapter.searchables_names.include?(q.field)
      end

      # Remove all aggregations with an empty value
      @aggregations = @aggregations.reject do |a|
        a.value.blank?
      end

      # Make sure aggregations are unique
      @aggregations = @aggregations.uniq

      # Remove all aggregations with unknown fields
      @aggregations = @aggregations.reject do |a|
        !adapter.aggregations_names.include?(a.field)
      end

      # Remove sort for unknown field
      if @sort && !adapter.sortables_names.include?(@sort.field)
        @sort = nil
      end

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
        field = q.field
        field = "-#{field}" if q.exclude
        value = Addressable::URI.encode_component(q.value, Addressable::URI::CharacterClasses::UNRESERVED)
        "sr[q,#{field}]=#{value}"
      end

      aggregations = @aggregations.map do |a|
        field = a.field
        field = "-#{field}" if a.exclude
        value = Addressable::URI.encode_component(a.value, Addressable::URI::CharacterClasses::UNRESERVED)
        "sr[a,#{field}]=#{value}"
      end

      sort = []
      if @sort
        sort << "sr[s,#{@sort.field}]=#{@sort.direction}"
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
