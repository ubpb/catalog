class Ils
  class Adapter < BaseAdapter

    def current_loans_sortable_fields
      raise NotImplementedError, "Implement this method in #{self.class.name}"
    end

    def current_loans_sortable_default_field
      raise NotImplementedError, "Implement this method in #{self.class.name}"
    end

    def current_loans_sortable_default_direction
      raise NotImplementedError, "Implement this method in #{self.class.name}"
    end

    def former_loans_sortable_fields
      raise NotImplementedError, "Implement this method in #{self.class.name}"
    end

    def former_loans_sortable_default_field
      raise NotImplementedError, "Implement this method in #{self.class.name}"
    end

    def former_loans_sortable_default_direction
      raise NotImplementedError, "Implement this method in #{self.class.name}"
    end

  end
end
