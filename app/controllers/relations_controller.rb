class RelationsController < RecordsController

  def index
    add_breadcrumb(t(".breadcrumb"), record_relations_path(
      search_scope: current_search_scope,
      record_id: @record.id
    ))

    @relations = @record.relations.select do |relation|
      if relation.id.present?
        SearchEngine[current_search_scope]
          .get_record(relation.id, by_all_other_ids: true)
          .present?
      end
    end.compact
  end

end
