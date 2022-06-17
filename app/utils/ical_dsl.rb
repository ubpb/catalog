module IcalDsl

  class Calendar
    def self.build(&block)
      Block.new("VCALENDAR", &block)
    end

    private

    # http://www.dan-manges.com/blog/ruby-dsls-instance-eval-with-delegation
    class Block
      def initialize(key, &block)
        @key        = key
        @components = []
        @self_before_instance_eval = eval("self", block.binding)
        instance_eval(&block)
      end

      def item(key, value, options = {})
        @components << Item.new(key, value, options)
      end

      def block(key, &block)
        @components << Block.new(key, &block)
      end

      def to_s
        "BEGIN:#{@key}\r\n" +
        @components.map(&:to_s).join +
        "END:#{@key}\r\n"
      end

      def method_missing(method, *args, &block)
        @self_before_instance_eval.send method, *args, &block
      end
    end

    class Item
      MAX_LINE_LENGTH = 75

      def initialize(key, value, options)
        @key   = key
        @value = sanitizing(value, options)
      end

      def sanitizing(value, options)
        options.symbolize_keys!

        if value.is_a?(Date)
          format_date(value)
        elsif value.is_a?(DateTime) || value.is_a?(ActiveSupport::TimeWithZone)
          format_date_time(value)
        else
          value = escape_chars(value)    if options[:escape] == true
          value = fold_long_lines(value) if options[:fold]   == true
          value
        end
      end

      def format_date(date)
        date.strftime '%Y%m%d'
      end

      def format_date_time(date_time)
        date_time.strftime '%Y%m%dT%H%M%S'
      end

      def fold_long_lines(value)
        folded  = ""
        chars   = value.chars
        folded << chars.shift(MAX_LINE_LENGTH).join << "\r\n " while chars.length != 0
        folded.strip
      end

      def escape_chars(value)
        value.gsub("\\", "\\\\").gsub("\r\n", "\n").gsub("\r", "\n").gsub("\n", "\\n").gsub(",", "\\,").gsub(";", "\\;")
      end

      def to_s
        "#{@key}:#{@value}\r\n"
      end
    end
  end

end
