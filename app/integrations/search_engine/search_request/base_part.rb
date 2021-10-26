class SearchEngine
  class SearchRequest

    class BasePart
      attr_reader :name
      attr_reader :value
      attr_reader :exclude

      def initialize(name:, value:, exclude: false)
        self.name = name
        self.value = value
        self.exclude = exclude
      end

      def name=(value) ; @name = value&.to_s ; end
      def value=(value) ; @value = value&.to_s ; end
      def exclude=(value) ; @exclude = value == true ; end

      def ==(other)
        self.name  == other&.name &&
        self.value == other&.value
      end

      def eql?(other)
        self == other
      end
    end

  end
end
