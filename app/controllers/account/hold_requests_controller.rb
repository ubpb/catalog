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

  def destroy
    if delete_hold_request(params[:id])
      flash[:success] = t(".success")
    else
      flash[:error] = t(".error")
    end

    redirect_to(account_hold_requests_path)
  end

private

  def load_hold_requests
    Ils[:default].get_hold_requests(
      current_user.ils_primary_id
    )
  end

  def delete_hold_request(request_id)
    Ils[:default].cancel_hold_request(
      current_user.ils_primary_id,
      request_id
    )
  end

end
