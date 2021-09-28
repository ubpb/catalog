class SearchEngine
  class SearchRequest

    class Page
      PER_PAGE_DEFAULT = 10
      PER_PAGE_MAX     = 100
      PAGE_DEFAULT     = 1

      attr_reader :page
      attr_reader :per_page

      def initialize(page = PAGE_DEFAULT, per_page: PER_PAGE_DEFAULT)
        self.page = page
        self.per_page = per_page
      end

      def page=(value)
       _value = value.to_i
       @page = (_value <= 0) ? PAGE_DEFAULT : _value
      end

      def per_page=(value)
        _value = value.to_i
        _value = (_value <= 0) ? PER_PAGE_DEFAULT : _value
        @per_page = (_value >= 100) ? PER_PAGE_MAX : _value
      end

      def first_page?
        page == 1
      end

      def from
        (@page - 1) * @per_page
      end

      def size
        @per_page
      end
    end

  end
end
