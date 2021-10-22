class SearchEngine
  class SearchRequest

    class Sort
      DIRECTIONS = ["asc", "desc"]
      DEFAULT_DIRECTION = "desc"

      attr_reader :name
      attr_reader :direction

      def initialize(name:, direction: DEFAULT_DIRECTION)
        self.name = name
        self.direction = direction
      end

      def name=(value)
       @name = value&.to_s
      end

      def direction=(value)
        @direction = DIRECTIONS.find{|d| d == value&.to_s&.downcase} || DEFAULT_DIRECTION
      end
    end

  end
end
