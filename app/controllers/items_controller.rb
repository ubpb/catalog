class ItemsController < RecordsController

  def index
    add_breadcrumb(t(".breadcrumb"), record_items_path(
      search_scope: current_search_scope,
      record_id: @record.id
    ))

    @items  = []
    @items += Ils.get_items(@record.id)
    @items += Ils.get_items(params[:host_item_id]) if params[:host_item_id].present?

    # Sort items and handle nil case for call number
    @items = @items.sort do |a, b|
      a.call_number && b.call_number ? a.call_number <=> b.call_number : a.call_number ? -1 : 1
    end

    if @items.present?
      # Augment item location label with data from the static location
      # lookup table.
      @items = augment_locations(@items)

      # Item stats
      @no_of_items = @items.count
      @no_of_available_items = @items.count{|i| i.is_available == true}

      # Get hold requests for that record
      @hold_requests = Ils.get_hold_requests_for_record(@record.id)

      if current_user.present?
        # Check if the current user can perform a hold request for that record
        @can_perform_hold_request = Ils.can_perform_hold_request(
          @record.id,
          current_user.ils_primary_id
        )

        # Check if the current user has a hold request for that record
        @user_hold_requests = @hold_requests.select do |hr|
          hr.user_id == current_user.ils_primary_id
        end
      end
    end
  end

private

  def augment_locations(items)
    items.each do |item|
      if item.location.present?
        location_code = item.location.code.presence
        notation      = item.call_number.try(:[], /\A[A-Z]{1,3}/).presence

        if location_code && notation
          LOCATION_LOOKUP_TABLE.find do |row|
            systemstellen_range = row[:systemstellen]
            standortkennziffern = row[:standortkennziffern]

            if systemstellen_range.present? && systemstellen_range.first.present? && systemstellen_range.last.present? && standortkennziffern.present?
              # Expand systemstellen and notation to 4 chars to make ruby range include? work in this case.
              justified_systemstellen_range = (systemstellen_range.first.ljust(4, "A") .. systemstellen_range.last.ljust( 4, "A"))
              justified_notation = notation.ljust(4, "A")

              standortkennziffern.include?(location_code) && justified_systemstellen_range.include?(justified_notation)
            end
          end.try do |row|
            item.location.attributes[:label] = row[:location]
          end
        end
      end
    end
  end

end
