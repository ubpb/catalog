class Operation

  def initialize(adapter)
    @adapter = adapter
  end

  attr_reader :adapter

  def call(*args)
    raise NotImplementedError, "Implement this method in #{self.class.name}"
  end

  #
  # We try to find an operation class. If successfull, the operation class
  # is instantiated and called with the given parameters. Otherwise we will raise a
  # NotImplementedError.
  #
  module TryOperation
    def try_operation(method_name, *args)
      op_class = begin
        op_class_name = "#{method_name.to_s.camelcase}Operation"
        self.class.const_get(op_class_name)
      rescue NameError
       raise NotImplementedError, <<-EOT.strip_heredoc
         Implement `##{method_name}` in `#{self.class.name}` or create the operation class `#{self.class}::#{op_class_name}`.
       EOT
      end

      if op_class
        begin
          op_class.new(self).call(*args)
        rescue => e
         # Wrap all errors from integrations into an IntegrationError
         raise IntegrationError
        end
      end
    end
  end

end
