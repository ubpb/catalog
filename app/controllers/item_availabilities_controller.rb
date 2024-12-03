class ItemAvailabilitiesController < RecordsController

  def index
    # Load items
    items = []
    items += Ils.get_items(@record.id)
    items += Ils.get_items(params[:host_item_id]) if params[:host_item_id].present?

    # Calculate general item availability
    @general_item_availability = calculate_general_item_availability(items)
  end

  private

  def calculate_general_item_availability(items)
    if items.blank?
      Ils::Item::AVAILABILITY_STATES[:unknown]
    elsif items.any? { |item| item.availability == Ils::Item::AVAILABILITY_STATES[:loanable] }
      Ils::Item::AVAILABILITY_STATES[:loanable]
    elsif items.any? { |item| item.availability == Ils::Item::AVAILABILITY_STATES[:restricted_loanable] }
      Ils::Item::AVAILABILITY_STATES[:restricted_loanable]
    elsif items.any? { |item| item.availability == Ils::Item::AVAILABILITY_STATES[:available] }
      Ils::Item::AVAILABILITY_STATES[:available]
    elsif items.all? { |item| item.availability == Ils::Item::AVAILABILITY_STATES[:unavailable] }
      Ils::Item::AVAILABILITY_STATES[:unavailable]
    else
      Ils::Item::AVAILABILITY_STATES[:unknown]
    end
  end

end
