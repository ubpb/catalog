class RecordsController < ApplicationController

  before_action :load_record

  def show
    # augment journal stock locations label with data from the static location
    # lookup table.
    @record = augment_journal_stock_locations(@record)

    # Remember return path. Used in view setup authentication links
    # that can be used to bring the user back to the current record
    # after authentication.
    @return_uri = sanitize_uri(request.fullpath)

    respond_to do |format|
      format.html
      format.json { render json: @record.to_json }
      format.bibtex { send_data BibtexExporter.parse(@record) }
    end
  end

  private

  def augment_journal_stock_locations(record)
    record.journal_stocks.each do |js|
      if js.call_number.present? && js.location_code.present?
        if (jls = journal_locations(js.call_number, js.location_code, stock: [js.label])).present?
          js.attributes[:location_name] = jls.join("; ")
        end
      end
    end

    record
  end

  def load_record
    # Load record by the given id
    @record = SearchEngine[current_search_scope].get_record(
      params[:record_id] || params[:id],
      on_campus: on_campus?
    )

    # In case of a local search try Aleph ID field if the record is blank?
    if current_search_scope == :local && @record.blank?
      @record = SearchEngine[current_search_scope].get_record(
        params[:record_id] || params[:id],
        by_other_id: "aleph_id"
      )

      if @record
        redirect_to(show_record_path(@record)) and return
      end
    end

    # Check for search request and validate it if available
    if request.params&.include?("sr")
      search_request = SearchEngine::SearchRequest.parse(request.url)
      validated_search_request = search_request.validate!(SearchEngine[current_search_scope].adapter)

      if validated_search_request.nil?
        redirect_to(show_record_path(@record)) and return
      elsif validated_search_request != search_request
        redirect_to(show_record_path(@record, search_request: validated_search_request)) and return
      else
        @search_request = validated_search_request

        if defined?(NewRelic) && @search_request.present?
          NewRelic::Agent.add_custom_attributes(search_request: @search_request.as_json)
        end
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

    true
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
    extended_search_result = SearchEngine[current_search_scope].search(
      extended_search_request,
      {
        session_id: request&.session&.id,
        on_campus: on_campus?
      }
    )

    if extended_search_result&.hits.present?
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
