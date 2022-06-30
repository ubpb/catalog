class SearchEngine
  class Aggregations::HistogramAggregation < Aggregations::Base

    class Value < BaseStruct
      attribute :key,   Types::Integer
      attribute :count, Types::Integer.default(0)
    end

    attribute :values, Types::Array.of(Value)

    def lowest_value
      values.first
    end

    def highest_value
      values.last
    end

    def chart_data
      if lowest_value&.key && highest_value&.key
        (lowest_value.key..highest_value.key).step(1).map do |key|
          {
            x: key.to_s,
            y: values.find{|v| v.key == key}&.count || 0
          }
        end
      else
        []
      end
    end

  end
end
