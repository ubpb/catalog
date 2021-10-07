class Compat::V1SearchesController < Compat::ApplicationController

  # Example:
  #   /searches?id=XXXX&scope=catalog
  #   /searches?q=XXXX&scope=catalog
  #   /searches?query_terms[]["if"]=any&query_terms[]["q"]=FOO&on_campus=true&sf=rank
  def index
    if params[:id]
      handle_id_query
    elsif params[:q]
      handle_simple_query
    elsif params[:query_terms]
      handle_query_terms_query
    else
      redirect_to(root_path)
    end
  end

  # Example:
  #   /searches/:hashed_id
  #   /searches/8muct9
  #
  # There is an old "searches" DB table that stores v1.x searches.
  # These searches can be found using a hashed ID. We want to get rid of
  # the table, because this old searches basically never occur in the
  # last 2-3 years. Because of that we just inform the user and redirect
  # to the home page.
  def show
    handle_hashed_id_query
  end

private

  def get_search_scope
    case params["scope"]
    when "primo_central" then "cdi"
    else "local"
    end
  end

  def handle_id_query
    record_id = params[:id]

    if record_id.upcase.starts_with?("PAD_ALEPH") # Local record
      redirect_to(record_path(id: record_id.gsub(/PAD_ALEPH/i, ""), search_scope: "local"))
    else # CDI record
      redirect_to(record_path(id: record_id, search_scope: "cdi"))
    end
  end

  def handle_simple_query
    query = SearchEngine::SearchRequest::Query.new(
      field: "any",
      value: params[:q]
    )

    search_request = SearchEngine::SearchRequest.new(queries: [query])

    sr_path = new_search_request_path(search_request, search_scope: get_search_scope)
    redirect_to(sr_path)
  end

  def handle_query_terms_query
    flash[:warning] = t("compat.v1_searches.unsupported_query_warning")
    redirect_to(root_path)
  end

  def handle_hashed_id_query
    flash[:warning] = t("compat.v1_searches.unsupported_query_warning")
    redirect_to(root_path)
  end

end
