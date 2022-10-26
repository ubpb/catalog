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

    # For journal Stücktitel load holdings. We use this to
    # inform the user about Stücktitel locations.
    if @record.is_journal_stücktitel?
      # To give the user information about the location of the journal, we load the
      # holdings for this journal Stücktitel record and pick the first one with a journal signature.
      # TODO: Are there cases where more than one holding exists for the journal Stücktitel.
      holdings_for_journal_stücktitel = Ils.get_holdings(@record.id)
      holdings_for_journal_stücktitel = holdings_for_journal_stücktitel.select{|h| journal_call_number?(h.call_number)}
      holdings_for_journal_stücktitel = augment_locations(holdings_for_journal_stücktitel)
      @holding_for_journal_stücktitel = holdings_for_journal_stücktitel.first
      # For the reference to the journal we pick the first "is part of" reference.
      # TODO: Are there cases where a journal Stücktitel is linked to more than one journal?
      @journal_for_stücktitel, @volume_for_stücktitel = @record.is_part_of.first&.label&.split(":")&.map(&:strip)&.map(&:presence)
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

  def augment_locations(items_or_holdings)
    items_or_holdings.each do |ioh|
      if ioh.call_number.present? && ioh.location&.code.present?
        if journal_call_number?(ioh.call_number)
          if (jls = journal_locations(ioh.call_number, ioh.location.code)).present?
            ioh.location.attributes[:label] = jls.join("; ")
          end
        else
          if (ml = mono_location(ioh.call_number, ioh.location.code)).present?
            ioh.location.attributes[:label] = ml
          end
        end
      end
    end

    items_or_holdings
  end

end
