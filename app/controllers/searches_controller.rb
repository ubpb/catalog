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
    search_request = SearchEngine::SearchRequest.parse(request.url)

    # Validate the search request in the context of the current search engine adapter.
    # #validate! returns a validated search request object or nil in case
    # the search request does not contain a valid search request. The validated
    # search request may be different from the one given by the request URL.
    # In that case a redirect is needed to reflect the validated params in the URL.
    validated_search_request = search_request.validate!(SearchEngine[current_search_scope].adapter)

    if validated_search_request.nil?
      # Search request was invalid. Inform the user that the search was invalid and
      # redirect to a new default search panel.
      flash[:search_panel] = {error: t("searches.request_hints.invalid_after_validation")}
      redirect_to(new_search_request_path)
    elsif validated_search_request != search_request
      # The validated search request is different from the given search request. That means
      # the validation changed the search request. To reflect the changes in the browser
      # we redirect to validated search request.
      redirect_to(new_search_request_path(validated_search_request))
    else
      # The search request is valid and was unchanged during validation.
      # Perform the search request against the selected search scope
      @search_request = validated_search_request

      if defined?(NewRelic)
        NewRelic::Agent.add_custom_attributes(search_request: @search_request.as_json)
      end

      @search_result = SearchEngine[current_search_scope].search(
        validated_search_request,
        {
          session_id: request&.session&.id,
          on_campus: on_campus?
        }
      )
    end
  end


  def create
    queries = []

    params[:q].each.with_index do |query, index|
      next if query.blank?

      queries << SearchEngine::SearchRequest::Query.new(
        name: params[:f][index].presence || "any",
        value: query
      )
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
