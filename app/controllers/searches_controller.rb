class SearchesController < ApplicationController

  before_action { add_breadcrumb t("searches.breadcrumb"), searches_path }
  before_action { add_breadcrumb t("searches.#{current_search_scope}.breadcrumb", default: "n.n."), nil }
  before_action :ensure_valid_search_scope

  def index
    # We can't use params, because the query syntax is incompatible
    # on how Rails parses the query part of the url (more than one parameter
    # with the same name).
    if query_string = Addressable::URI.parse(request.url).query
      @search_request = SearchEngine::SearchRequest.parse(query_string)
      @search_result  = SearchEngine[current_search_scope].search(@search_request)
    end
  end

  # Called from search panel form submit.
  def create
    sr_parts = []

    params[:q].each do |field, values|
      values.each do |value|
        sr_parts << SearchEngine::SearchRequest::RequestPart.new(
          query_type: "query",
          field: field,
          value: value
        )
      end
    end

    sr = SearchEngine::SearchRequest.new(sr_parts)

    redirect_path = "#{searches_path(search_scope: current_search_scope)}?#{sr.query_string}"
    redirect_to(redirect_path)
  end

private

  def ensure_valid_search_scope
    requested_search_scope = available_search_scopes.find{|_| _ == params[:search_scope]&.to_sym}

    unless requested_search_scope
      redirect_to(searches_path(search_scope: available_search_scopes.first))
      false
    end

    true
  end

end
