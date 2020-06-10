class Account::HoldRequestsController < Account::ApplicationController

  def index
    if request.xhr?
      # Load hold requests
      hold_requests = load_hold_requests
      # Sort by request date desc
      hold_requests = hold_requests.sort{|x,y| y.requested_at <=> x.requested_at}

      # Render hold request listing
      render partial: "hold_requests", locals: {
        hold_requests: hold_requests
      }
    else
      render :index
    end
  end

private

  def load_hold_requests
    Ils[:default].get_hold_requests(
      current_user.ils_primary_id
    )
  end

end
