class VolumesController < RecordsController

  def self.search_request(record)
    # The superorder_id of the volumes is always the hbz_id or the zdb_id of the given record.
    # If zdb_id is present we will link using the zdb_id, otherwise we will link using the hbz_id.
    superorder_id = record.zdb_id.presence || record.hbz_id.presence || ""

    SearchEngine::SearchRequest.parse("sr[q,superorder_id]=#{superorder_id}&sr[s,asc]=volume")
  end

  def index
    add_breadcrumb(
      t(".breadcrumb"),
      record_volumes_path(
        search_scope: current_search_scope,
        record_id:    @record.id
      )
    )

    results = SearchEngine[current_search_scope].search(VolumesController.search_request(@record))

    @has_volumes = if results&.total&.positive?
                     true
                   else
                     false
                   end
  end

end
