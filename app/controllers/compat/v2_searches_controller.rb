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
      rescue JSON::ParserError
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

  def map_query_field(v2_field)
    case v2_field
    when "custom_all"                  then "any"
    when "creator_contributor_search"  then "creator"
    when "title_search"                then "title"
    when "subject_search"              then "subject"
    when "publisher"                   then "pub"
    when "toc"                         then "any" # TODO: Change to toc if toc is available
    when "creationdate_search"         then "yop"
    when "isbn_search"                 then "ids"
    when "issn"                        then "ids"
    when "signature_search"            then "call_number"
    when "notation"                    then "local_notation"
    when "ht_number"                   then "ids"
    when "superorder"                  then "superorder_id"
    when "selection_code"              then "any"
    when "oclc_id"                     then "ids"
    when "collection_code"             then "any"
    else "any"
    end
  end

  def map_sort_field(v2_field)
    case v2_field
    when "creator_contributor_facet" then "creator"
    when "creationdate_facet"        then "yop"
    when "notation_sort"             then "local_notation"
    when "title_sort"                then "title"
    when "volume_count_sort"         then "volume"
    when "volume_count_sort2"        then "volume"
    when "cataloging_date"           then "newrecords"
    else nil
    end
  end

  def map_aggregation_field(v2_field)
    case v2_field
    when "materialtyp_facet"         then "material_type"
    when "creator_contributor_facet" then "creator"
    when "erscheinungsform_facet"    then "resource_type"
    when "subject_facet"             then "subject"
    when "creationdate_facet"        then "yop"
    when "language_facet"            then "language"
    when "notation_facet"            then "local_notation"
    when "inhaltstyp_facet"          then "content_type"
    when "cataloging_date"           then "newrecords"
    else "any"
    end
  end

  def handle_isbn_query(isbn)
    search_request = SearchEngine::SearchRequest.new(queries: [
      SearchEngine::SearchRequest::Query.new(
        name: "isbn",
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
        name: "issn",
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
        name: "oclc_id",
        value: oclc_id
      )
    ])

    redirect_to(
      new_search_request_path(search_request, search_scope: "local")
    )
  end

  def handle_search_request(search_request)
    queries = (search_request["queries"] || []).map do |query|
      if field = map_query_field(query["fields"].first)
        SearchEngine::SearchRequest::Query.new(
          name: field,
          value: query["query"]
        )
      end
    end.compact

    if sort_field = map_sort_field((search_request["sort"] || []).first&.dig("field"))
      sort = SearchEngine::SearchRequest::Sort.new(
        name: sort_field,
        direction: (search_request["sort"] || []).first&.dig("order") || "asc"
      )
    end

    aggregations = (search_request["facet_queries"] || []).map do |facet|
      if field = map_aggregation_field(facet["field"])
        if field == "yop"
          SearchEngine::SearchRequest::Aggregation.new(
            name: field,
            value: "#{facet["gte"]}..#{facet["lte"]}"
          )
        elsif field == "newrecords"
          SearchEngine::SearchRequest::Aggregation.new(
            name: field,
            value: facet["gte"]
          )
        else
          SearchEngine::SearchRequest::Aggregation.new(
            name: field,
            value: facet["query"],
            exclude: facet["exclude"] == "true"
          )
        end
      end
    end.compact

    search_request = SearchEngine::SearchRequest.new(
      queries: queries,
      aggregations: aggregations,
      sort: sort
    )


    redirect_to(
      new_search_request_path(search_request, search_scope: get_search_scope)
    )
  end

end
