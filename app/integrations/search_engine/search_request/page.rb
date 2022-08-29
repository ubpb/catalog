class SearchEngine
  class SearchRequest

    class Page
      PER_PAGE_DEFAULT = 25
      PER_PAGE_MAX     = 100
      PAGE_DEFAULT     = 1
      PAGE_MAX         = 100

      attr_reader :page
      attr_reader :per_page

      def initialize(page = PAGE_DEFAULT, per_page: PER_PAGE_DEFAULT)
        self.page = page
        self.per_page = per_page
      end

      def page=(value)
       @page = value.to_i
      end

      def per_page=(value)
        @per_page = value.to_i
      end

      def first_page?
        page == 1
      end

      def last_page?(total)
        page == total.fdiv(per_page).ceil ||
        page >= PAGE_MAX
      end

      def from=(value)
        _value = value.to_i
        @from = (_value < 0) ? 0 : _value
        @page = @from.fdiv(per_page).ceil
      end

      def from
        if @from.present?
          @from
        else
          (@page - 1) * @per_page
        end
      end

      def size
        @per_page
      end

      def ==(other)
        self.page     == other&.page &&
        self.per_page == other&.per_page
      end

      def eql?(other)
        self == other
      end

      def validate!(adapter)
        vp = self.dup

        vp.page = PAGE_DEFAULT if self.page <= 0
        vp.page = PAGE_MAX     if self.page > PAGE_MAX

        vp.per_page = PER_PAGE_DEFAULT if self.per_page <= 0
        vp.per_page = PER_PAGE_MAX     if self.per_page > PER_PAGE_MAX

        return vp
      end
    end

  end
end
