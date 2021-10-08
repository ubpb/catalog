class ItemsController < ApplicationController

  def index
    record_id = "9944643600649" # Fix ID from Sandbox for testing
    @items = Ils.get_items(record_id)
  end

end
