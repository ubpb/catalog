class Operation

  def initialize(adapter)
    @adapter = adapter
  end

  attr_reader :adapter

  def call(*args)
    raise NotImplementedError, "Implement this method in #{self.class.name}"
  end

end
