class ItemsController < ApplicationController

  TEST_RECORDS = [
    "99943610000541",
    "9944643600649",
    "991195150000541",
    "99926630000541",
    "991450290000541",
    "991379170000541"
  ]

  def index
    @record_id = params[:record_id]
    @items     = Ils.get_items(TEST_RECORDS.sample) # TODO: Remove fake ID
  end

end
