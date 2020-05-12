class BaseAdapter
  def initialize(options = {})
    @options = options
    @logger  = Rails.logger
  end

  attr_reader :options
  attr_reader :logger
end
