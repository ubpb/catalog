class SearchEngine
  class SearchRequest

    class Sort
      DIRECTIONS = ["asc", "desc"]
      DEFAULT_DIRECTION = "desc"

      attr_reader :field
      attr_reader :direction

      def initialize(field:, direction: DEFAULT_DIRECTION)
        self.field = field
        self.direction = direction
      end

      def field=(value)
       @field = value&.to_s
      end

      def direction=(value)
        @direction = DIRECTIONS.find{|d| d == value&.to_s&.downcase} || DEFAULT_DIRECTION
      end
    end

  end
end
