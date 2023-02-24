class ItemsController < RecordsController

  def index
    @return_uri = sanitize_return_uri(params[:return_uri])

    add_breadcrumb(t(".breadcrumb"), record_items_path(
      search_scope: current_search_scope,
      record_id: @record.id
    ))

    @items  = []
    @items += Ils.get_items(@record.id)
    @items += Ils.get_items(params[:host_item_id]) if params[:host_item_id].present?

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

    # Handle the case where we want a special "journal listing" for the items
    if @record.is_journal? || @record.is_newspaper?
      # Make sure we render the special journal listing
      @show_journal_listing = true

      # For journals only show the current and expected items or items that have a public note set
      @items = @items.select { |i| i.expected_or_current_issue? || i.public_note.present? }

      # Prepare items for display...
      if @items.present?
        # Create sort key to sort the items.
        # Sort journal items by description: The description holds the issue number.
        # But the format is not always in a sortable form, so we fix the common ones
        # "n.yyyy", "n.yyyy,m" and "yyyy,n" and make them sortable.
        @items = @items.map do |item|
          sort_key = case item.description
                     # n.yyyy,m
                     when /(\d{1,2})\.(\d{4}),(\d{1,2})/ then "#{$2.rjust(4, '0')}-#{$1.rjust(4, '0')}-#{$3.rjust(4, '0')}"
                     # n.yyyy
                     when /(\d{1,2})\.(\d{4})/           then "#{$2.rjust(4, '0')}-#{$1.rjust(4, '0')}-0000"
                     # yyyy,n
                     when /(\d{4}),(\d{1,2})/            then "#{$1.rjust(4, '0')}-#{$2.rjust(4, '0')}-0000"
                     # yyyy
                     when /(\d{4})/                      then "#{$1.rjust(4, '0')}-0000-0000"
                     # ...
                     else item.description
                     end

          item.new(sort_key:)
        end

        # Finally sort the items
        @items = @items.sort_by(&:sort_key)
      end
    else
      # Make sure we render the normal items listing
      @show_journal_listing = false

      # Prepare items for display...
      if @items.present?
        # Sort items by call number. Handle nil case for call number (sorted last)
        @items = @items.sort_by{|item| [item.call_number ? 1 : 0, item.call_number]}

        # Augment item location label with data from the static location lookup table
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
