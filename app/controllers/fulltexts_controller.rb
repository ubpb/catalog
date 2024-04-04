class FulltextsController < RecordsController

  before_action { add_breadcrumb(t("fulltexts.breadcrumb"), record_fulltexts_path(@record, search_request: @search_request)) }

  def index
    @fulltexts = FulltextService.resolve(@record)
  rescue => e
    Rails.logger.error [e.message, *Rails.backtrace_cleaner.clean(e.backtrace)].join($/)
    render "fulltexts/error"
  end

end
