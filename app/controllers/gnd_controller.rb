class GndController < ApplicationController

  def show
    sleep(2)
    if turbo_frame_request?
      render "show-modal"
    else
      render "show"
    end
  end

end
