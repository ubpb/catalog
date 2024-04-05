class LibKeyService::Result

  attr_reader :url, :browzine_link

  def initialize(url:, browzine_link:)
    @url = url
    @browzine_link = browzine_link
  end

end
