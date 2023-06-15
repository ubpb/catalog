class ExpandableListComponent < ViewComponent::Base
  include ViewComponent::Translatable

  def initialize(items:, initial_items: 4, list_options: {}, item_options: {})
    @items = items
    @initial_items = initial_items
    @list_options = list_options
    @item_options = item_options
  end

end
