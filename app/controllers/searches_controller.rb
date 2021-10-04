class SearchesController < ApplicationController

  before_action { add_breadcrumb t("searches.breadcrumb"), searches_path }
  before_action { add_breadcrumb t("searches.#{current_search_scope}.breadcrumb", default: "n.n."), nil }
  before_action :ensure_valid_search_scope

  def index
    # Return if there are no query string params that may contain a search request.
    # This allows us to display the search panel and let the user switch between the
    # search scope tabs.
    return unless request.url.include?("?")

    # There is a query string available. Let's try to parse it for a proper
    # search request. We can't use Rails params hash, because the query syntax
    # is incompatible with how Rails parses the query part of the url
    # (more than one parameter with the same name).
    @search_request = SearchEngine::SearchRequest.parse(request.url)

    # Validate the request in the context of the current search scope.
    # Be aware that the validate! method is destructive. It manipulates
    # the search request by removing all parts that are not valid
    # based on search scope configuration. The method returns true if no
    # changes where made. After validation the remaining search request
    # is either valid or empty and these cases must also be handled.
    if @search_request.validate!(search_scope: current_search_scope)
      # The request is valid and was unchanged during validation.
      # Perform the search request against the selected search scope
      @search_result = SearchEngine[current_search_scope].search(
        @search_request,
        {
          session_id: request&.session&.id
        }
      )
    elsif @search_request.empty?
      # The request was changed during validation and is empty now. Let's
      # inform the user and redirect to a default state.
      flash[:search_panel] = {error: t("searches.request_hints.empty_after_validation")}
      redirect_to(new_search_request_path)
    else
      # The request was changed during validation but is not empty. That means
      # we now have a valid search request. To reflect that in the url let's trigger
      # the search request (now with a valid query string) and inform the user about the
      # change.
      flash[:search_panel] = {info: t("searches.request_hints.modified_during_validation")}
      redirect_to(new_search_request_path(@search_request))
    end
  end


  def create
    queries = []

    params[:q].each do |field, values|
      values.each do |value|
        queries << SearchEngine::SearchRequest::Query.new(
          field: field,
          value: value
        )
      end
    end

    sr = SearchEngine::SearchRequest.new(queries: queries)
    redirect_to(new_search_request_path(sr))
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
