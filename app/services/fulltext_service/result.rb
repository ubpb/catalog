class FulltextService::Result

  attr_reader :url, :source

  def initialize(url:, source:)
    @url = url
    @source = source
  end

end
