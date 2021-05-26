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

      # Extract default options from the query string. These options must
      # be passed to SearchEngine#search to activate the integrated "pagination"
      # feature.
      page     = @search_request.options.delete("page")
      per_page = @search_request.options.delete("per_page")

      # First check if the given request is empty. Then
      # validate the request in the context of the current search scope.
      # Be aware that the validate method is destructive. It manipulates
      # the search request by removing all parts that are not valid
      # based on search scope configuration. The method returns true if no
      # changes where made. After validation the remaining search request
      # is either valid or empty and these cases must also be handled.
      if @search_request.empty?
        # The given search request is empty. Let's silently
        # redirect to a default state.
        redirect_to(new_search_request_path(nil))
      elsif @search_request.validate!(current_search_scope)
        # The request is valid and was unchanged during validation.
        # Perform the search request against the selected search scope
        @search_result = SearchEngine[current_search_scope].search(
          @search_request,
          {page: page, per_page: per_page}
        )
      elsif @search_request.empty?
        # The remaining request after validation is empty. Let's
        # redirect to a default state.
        flash[:search_panel] = {error: t("searches.request_hints.empty_after_validation")}
        redirect_to(new_search_request_path(nil))
      else
        # The remaining search request is now valid (after validation) and
        # not empty. In this case we just trigger the search request again
        # (now with a valid query string)
        flash[:search_panel] = {info: t("searches.request_hints.modified_during_validation")}
        redirect_to(new_search_request_path(@search_request))
      end
    end
  rescue SearchEngine::SearchRequest::SyntaxError => e
    flash[:search_panel] = {error: t("searches.request_hints.syntax_error")}
    redirect_to(new_search_request_path(nil))
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
