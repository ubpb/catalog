class Account::HoldRequestsController < Account::ApplicationController

  before_action { add_breadcrumb t("account.hold_requests.breadcrumb"), account_hold_requests_path }

  def index
    if request.xhr?
      render partial: "hold_requests", locals: {
        hold_requests: load_hold_requests
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

    redirect_to(account_hold_requests_path, status: :see_other)
  end

private

  def load_hold_requests
    Ils.get_hold_requests(
      current_user.ils_primary_id
    ).select do |hr|
      hr.is_resource_sharing_request == false
    end.sort do |x, y|
      y.requested_at <=> x.requested_at
    end
  end

  def delete_hold_request(request_id)
    Ils.cancel_hold_request(
      current_user.ils_primary_id,
      request_id
    )
  end

end
