class SearchEngine
  class SearchRequest

    class BasePart
      attr_reader :field
      attr_reader :value
      attr_reader :exclude

      def initialize(field:, value:, exclude: false)
        self.field = field
        self.value = value
        self.exclude = exclude
      end

      def field=(value) ; @field = value&.to_s ; end
      def value=(value) ; @value = value&.to_s ; end
      def exclude=(value) ; @exclude = value == true ; end

      def eql?(other)
        self.field == other.field &&
        self.value == other.value
      end
    end

  end
end
