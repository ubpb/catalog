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
    record_id = TEST_RECORDS.sample # TODO: Use real record id

    @items = Ils.get_items(record_id)
  end

end
