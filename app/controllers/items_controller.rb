class ItemsController < RecordsController

  def index
    @record_id    = @record.id
    @host_item_id = params[:host_item_id]

    @items  = []
    @items += Ils.get_items(@record_id)
    @items += Ils.get_items(@host_item_id) if @host_item_id.present?

    if @items.present?
      # Item stats
      @no_of_items = @items.count
      @no_of_available_items = @items.count{|i| i.is_available == true}

      # Get hold requests for that record
      @hold_requests = Ils.get_hold_requests_for_record(@record_id)

      if current_user.present?
        # Check if the current user can perform a hold request for that record
        @can_perform_hold_request = Ils.can_perform_hold_request(
          @record_id,
          current_user.ils_primary_id
        )

        # Check if the current user has a hold request for that record
        @user_hold_requests = @hold_requests.select do |hr|
          hr.user_id == current_user.ils_primary_id
        end
      end
    end

    add_breadcrumb(t(".breadcrumb"), record_items_path(
      search_scope: current_search_scope,
      record_id: @record.id
    ))
  end

end
