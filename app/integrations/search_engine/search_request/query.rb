class SearchEngine
  class SearchRequest

    class Query < BasePart

      DEFAULT_NAME = "any"

      def validate!(adapter)
        requested_searchable = adapter.searchables.find{|s| s[:name] == self.name}
        default_searchable   = adapter.searchables.find{|s| s[:name] == DEFAULT_NAME}

        if self.value.blank?
          return nil
        elsif requested_searchable.nil? && default_searchable.nil?
          return nil
        elsif requested_searchable.nil? && default_searchable.present?
          vq = self.dup
          vq.name = DEFAULT_NAME
          return vq
        else
          self
        end
      end

    end

  end
end
