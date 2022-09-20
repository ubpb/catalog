class VolumesController < RecordsController

  def self.search_request(record)
    # TODO: If superorder_id contains an Alma ID, linking using hbz_id will not work.
    # We need to fix this in normalisation. This will only become a problem if Alma is the leading
    # "Verbundsystem". Therefore we have some time to fix this.
    sr_to_volumes = SearchEngine::SearchRequest.parse("sr[q,superorder_id]=#{record.hbz_id}&sr[s,asc]=volume")
  end

  def index
    add_breadcrumb(t(".breadcrumb"), record_volumes_path(
      search_scope: current_search_scope,
      record_id: @record.id
    ))

    results = SearchEngine[current_search_scope].search(VolumesController.search_request(@record))

    if results && results.total > 0
      @volumes = true
    else
      @volumes = false
    end
  end

end
