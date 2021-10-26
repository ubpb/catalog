class SearchEngine
  class SearchRequest

    class Aggregation < BasePart

      def validate!(adapter)
        aggregation = adapter.aggregations.find{|s| s[:name] == self.name}

        if self.value.blank?
          return nil
        elsif aggregation.nil?
          return nil
        else
          self
        end
      end

    end

  end
end
