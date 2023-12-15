class Account::InterLibraryLoansController < Account::ApplicationController

  def index
    if turbo_frame_request?
      render partial: "listing", locals: {
        resource_sharing_requests: load_resource_sharing_requests
      }
    else
      render :index
    end
  end

  private

  def load_resource_sharing_requests
    Ils.get_hold_requests(
      current_user.ils_primary_id
    ).select do |hr|
      hr.is_resource_sharing_request == true
    end.sort do |x, y|
      y.requested_at <=> x.requested_at
    end
  end

end
