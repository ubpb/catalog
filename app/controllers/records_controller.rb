class RecordsController < ApplicationController

  before_action :load_record

private

  def load_record
    # Load record by the given id
    @record = SearchEngine[current_search_scope].get_record(
      params[:record_id] || params[:id],
      on_campus: on_campus?
    )

    # Check for search request and validate it if available
    if request.url.include?("?")
      search_request = SearchEngine::SearchRequest.parse(request.url)
      validated_search_request = search_request.validate!(SearchEngine[current_search_scope].adapter)

      if validated_search_request.nil?
        redirect_to(show_record_path(@record)) and return
      elsif validated_search_request != search_request
        redirect_to(show_record_path(@record, search_request: validated_search_request)) and return
      else
        @search_request = validated_search_request
      end
    end

    # Handle "record not found" case
    check_for_record(@record, @search_request) or return

    # Try to find previous and next record
    if @search_request
      find_previous_and_next_record(@search_request)
    end

    # Set breadcrumb
    add_breadcrumb(t("searches.breadcrumb"), new_search_request_path(@search_request)) if @search_request
    add_breadcrumb(t("records.breadcrumb"), show_record_path(@record, search_request: @search_request))
  end

  def check_for_record(record, search_request)
    unless record
      flash[:search_panel] = {error: "ERROR: Record not found"}
      if search_request
        redirect_to(new_search_request_path(search_request)) and return
      else
        redirect_to(new_search_request_path) and return
      end
    end

    return true
  end

  def find_previous_and_next_record(search_request)
    # Create an extended search request that overlaps the given search request
    # in a way that allows us to find the previous and next record across
    # pages.
    on_first_page                          = search_request.page.first_page?
    extended_search_request                = search_request.dup
    extended_search_request.page.from      = search_request.page.from - 1 unless on_first_page
    extended_search_request.page.per_page += on_first_page ? 1 : 2

    # Search the extended request, find the given record and determine the next
    # and previous records (if available)
    if (extended_search_result = SearchEngine[current_search_scope].search(
      extended_search_request,
      {
        session_id: request&.session&.id,
        on_campus: on_campus?
      }
    )).hits.present?
      # Extract hits
      hits = extended_search_result.hits
      # Remove edge case "first page" by prepending empty hit
      hits = [nil].concat(hits) if on_first_page
      # Remove edge case "page not full" / "last page" by appending empty hit
      hits = hits.concat([nil]) if hits.count < search_request.page.per_page
      # Find record within hits and select previous and next record if available
      if record_index = hits.find_index{|h| h && h.record.id == @record.id}
        @total_hits                    = extended_search_result.total
        @position_within_search_result = record_index + search_request.page.from

        is_first = record_index == 1
        is_last  = record_index == hits.count - 2

        # Find next record and a matching search request that contains this record
        @next_record = hits[record_index + 1]&.record
        if @next_record
          @next_record_search_request = search_request.dup
          @next_record_search_request.page.page += 1 if is_last
        end

        # Find previous record and a matching search request that contains this record
        @previous_record = hits[record_index - 1]&.record
        if @previous_record
          @previous_record_search_request = search_request.dup
          @previous_record_search_request.page.page -= 1 if is_first
        end
      end
    end
  end

end
