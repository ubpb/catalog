class LibKeyService::Result

  attr_reader :url, :browzine_url, :retraction_notice_url, :cover_image_url, :libkey_io_url

  def initialize(url:, browzine_url: nil, retraction_notice_url: nil, cover_image_url: nil, libkey_io_url: nil)
    @url = url
    @browzine_url = browzine_url
    @retraction_notice_url = retraction_notice_url
    @cover_image_url = cover_image_url
    @libkey_io_url = libkey_io_url
  end

end
