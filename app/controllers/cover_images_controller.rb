class CoverImagesController < RecordsController

  def index
    cover_image = CoverImageService.resolve(@record)
    send_data(cover_image, disposition: "inline", type: "image/png")
  end

end
