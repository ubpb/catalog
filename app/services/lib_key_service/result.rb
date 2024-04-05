class LibKeyService::Result

  attr_reader :url, :browzine_url, :retraction_notice_url

  def initialize(url:, browzine_url:, retraction_notice_url:)
    @url = url
    @browzine_url = browzine_url
    @retraction_notice_url = retraction_notice_url
  end

end
