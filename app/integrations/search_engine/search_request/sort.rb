class SearchEngine
  class SearchRequest

    class Sort
      DEFAULT_NAME      = "_default_"
      DIRECTIONS        = ["asc", "desc"]
      DEFAULT_DIRECTION = "asc"

      attr_reader :name
      attr_reader :direction

      def initialize(name: nil, direction: nil)
        self.name      = name
        self.direction = direction
      end

      def name=(value)
       @name = value.present? ? value.to_s : DEFAULT_NAME
      end

      def direction=(value)
        @direction = DIRECTIONS.find{|d| d == value&.to_s&.downcase} || DEFAULT_DIRECTION
      end

      def default?
        @name == DEFAULT_NAME
      end

      def default_direction?
        @direction == DEFAULT_DIRECTION
      end

      def ==(other)
        self.name == other.name &&
        self.direction == other.direction
      end

      def eql?(other)
        self == other
      end
    end

  end
end
