class SearchEngine
  class SearchRequest

    class Sort
      DEFAULT_NAME      = "_default_"
      DIRECTIONS        = ["asc", "desc"]
      DEFAULT_DIRECTION = "asc"

      attr_reader :name
      attr_reader :direction

      def self.default
        Sort.new(name: DEFAULT_NAME, direction: nil)
      end

      def initialize(name: nil, direction: nil)
        self.name      = name
        self.direction = direction
      end

      def name=(value)
       @name = value.present? ? value.to_s : DEFAULT_NAME
      end

      def direction=(value)
        @direction = value&.to_s
      end

      def default?
        self.name == DEFAULT_NAME
      end

      def ==(other)
        self.name      == other&.name &&
        self.direction == other&.direction
      end

      def eql?(other)
        self == other
      end

      def validate!(adapter)
        if default?
          return Sort.default
        end

        if (sortable = adapter.sortables.find{|s| s["name"] == self.name}).nil?
          return Sort.default
        end

        if omit_direction = sortable["omit_direction"] == true
          return Sort.new(name: self.name, direction: nil)
        end

        default_direction = sortable["default_direction"] || DEFAULT_DIRECTION
        direction = if self.direction.blank?
          default_direction
        else
          DIRECTIONS.find{|d| d == self.direction} || default_direction
        end
        return Sort.new(name: self.name, direction: direction)
      end
    end

  end
end
