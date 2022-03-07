class ItemsController < ApplicationController

  def index
    @record_id = params[:record_id]
    @items = load_items(
      @record_id,
      host_item_id: params[:host_item_id]
    )
  end

private

  def load_items(record_id, host_item_id: nil)
    items = []
    items += Ils.get_items(@record_id)
    items += Ils.get_items(host_item_id) if host_item_id
    items
  end

end
