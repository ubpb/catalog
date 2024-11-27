class ItemAvailabilitiesController < RecordsController

  def index
    # Load items
    items = []
    items += Ils.get_items(@record.id)
    items += Ils.get_items(params[:host_item_id]) if params[:host_item_id].present?

    # Calculate item availability
    @general_item_availablity = calculate_general_item_availability(items)
  end

  private

  def calculate_general_item_availability(items)
    if (items.any? {|item| item.availability == :available})
      :available
    elsif (items.any? {|item| item.availability == :restricted_available})
      :restricted_available
    elsif (items.all? {|item| item.availability == :unavailable})
      :unavailable
    else
      :unknown
    end
  end

end
