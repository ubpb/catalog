class Compat::V2SearchesController < Compat::ApplicationController

  def index
    if isbn = params[:isbn]
      handle_isbn_query(isbn)
    elsif issn = params[:issn]
      handle_issn_query(issn)
    elsif oclc_id = params[:oclc_id]
      handle_oclc_id_query(oclc_id)
    elsif search_request = params[:search_request]
      begin
        handle_search_request(JSON.parse(search_request))
      rescue #JSON::ParserError
        # Search request json is somewhat broken. Just redirect
        # to new search.
        flash[:warning] = t("compat.v2_searches.broken_search_request_warning")
        redirect_to(searches_path(search_scope: get_search_scope))
      end
    else
      # There was no search request available,
      # let's just redirect to a new search.
      redirect_to(searches_path(search_scope: get_search_scope))
    end
  end

private

  def get_search_scope
    case params[:search_scope]
    when "primo_central" then "cdi"
    when "cdi"           then "cdi"
    else "local"
    end
  end

  def map_query_field(v1_field)
    case v1_field
    when "custom_all"                  then "any"
    when "creator_contributor_search"  then "creator"
    when "title_search"                then "title"
    when "subject_search"              then "subject"
    when "publisher"                   then "publisher"
    when "toc"                         then "toc"
    when "creationdate_search"         then "creation_date"
    when "isbn_search"                 then "isbn"
    when "issn"                        then "issn"
    when "signature_search"            then "signature"
    when "notation"                    then "notation"
    when "ht_number"                   then "hbz_id"
    when "superorder"                  then "superorder"
    when "selection_code"              then "selection_code"
    when "oclc_id"                     then "oclc_id"
    when "collection_code"             then "collection_code"
    else "any"
    end
  end

  def map_aggregation_field(v1_field)
    case v1_field
    when "materialtyp_facet"         then "rtype"
    when "creator_contributor_facet" then "creator"
    when "erscheinungsform_facet"    then "erscheinungsform"
    when "subject_facet"             then "subject"
    when "creationdate_facet"        then nil
    when "language_facet"            then "language"
    when "notation_facet"            then "notation"
    when "inhaltstyp_facet"          then "inhaltstyp"
    when "cataloging_date"           then nil
    else "any"
    end
  end

  def handle_isbn_query(isbn)
    search_request = SearchEngine::SearchRequest.new(queries: [
      SearchEngine::SearchRequest::Query.new(
        field: "isbn",
        value: isbn
      )
    ])

    redirect_to(
      new_search_request_path(search_request, search_scope: "local")
    )
  end

  def handle_issn_query(issn)
    search_request = SearchEngine::SearchRequest.new(queries: [
      SearchEngine::SearchRequest::Query.new(
        field: "issn",
        value: issn
      )
    ])

    redirect_to(
      new_search_request_path(search_request, search_scope: "local")
    )
  end

  def handle_oclc_id_query(oclc_id)
    search_request = SearchEngine::SearchRequest.new(queries: [
      SearchEngine::SearchRequest::Query.new(
        field: "oclc_id",
        value: oclc_id
      )
    ])

    redirect_to(
      new_search_request_path(search_request, search_scope: "local")
    )
  end

  def handle_search_request(search_request)
    queries = search_request["queries"].map do |query|
      if field = map_query_field(query["fields"].first)
        SearchEngine::SearchRequest::Query.new(
          field: field,
          value: query["query"]
        )
      end
    end.compact

    aggregations = search_request["facet_queries"].map do |facet|
      if field = map_aggregation_field(facet["field"])
        SearchEngine::SearchRequest::Aggregation.new(
          field: field,
          value: facet["query"],
          exclude: facet["exclude"] == "true"
        )
      end
    end.compact

    search_request = SearchEngine::SearchRequest.new(
      queries: queries,
      aggregations: aggregations
    )

    redirect_to(
      new_search_request_path(search_request, search_scope: "local")
    )
  end

end
