class ItemAvailabilitiesController < RecordsController

  def index
    @general_item_availability = Rails.cache.fetch("#{@record.id}/item-availability", expires_in: 5.minutes) do
      # Load items
      items = []
      items += Ils.get_items(@record.id)
      items += Ils.get_items(params[:host_item_id]) if params[:host_item_id].present?

      # Calculate general item availability
      calculate_general_item_availability(items)
    end
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
