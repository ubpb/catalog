class FulltextsController < RecordsController

  before_action { add_breadcrumb(t("fulltexts.breadcrumb"), record_fulltexts_path(@record, search_request: @search_request)) }

  def index
    @fulltexts = FulltextService.resolve(@record)
  end

end
