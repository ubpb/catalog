class ItemsController < ApplicationController

  def index
    @record_id = params[:record_id]
    @items     = Ils.get_items(@record_id)
  end

end
