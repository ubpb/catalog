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

  def semapp_location
    @item_id  = params[:id]
    @username = Ils.get_semapp_location(@record.id, @item_id)
  end

private

  def augment_locations(items)
    items.each do |item|
      if item.call_number.present? && item.location&.code.present?
        if journal_call_number?(item.call_number)
          if (jls = journal_locations(item.call_number, item.location.code)).present?
            item.location.attributes[:label] = jls.join("; ")
          end
        else
          if (ml = mono_location(item.call_number, item.location.code)).present?
            item.location.attributes[:label] = ml
          end
        end
      end
    end

    items
  end

end
