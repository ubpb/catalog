class FulltextsController < RecordsController

  before_action { add_breadcrumb(t("fulltexts.breadcrumb"), record_fulltexts_path(@record, search_request: @search_request)) }

  def index
    @fulltext_service_results = FulltextService.resolve(@record)
  rescue => e
    Rails.logger.error [e.message, *Rails.backtrace_cleaner.clean(e.backtrace)].join($/)

    if (cause = e.cause)
      Rails.logger.error "#{$/}CAUSED BY:"
      Rails.logger.error [cause.message, *Rails.backtrace_cleaner.clean(cause.backtrace)].join($/)
    end

    @error = e
    render "fulltexts/error"
  end

end
