class HoldRequestsController < RecordsController

  before_action :authenticate!
  before_action :authorize!

  def create
    if Ils.create_hold_request(@record.id, current_user.ils_primary_id)
      flash[:success] = t(".success")
    else
      flash[:error] = t(".error")
    end

    redirect_to record_items_path(
      record_id: @record.id,
      search_scope: current_search_scope
    ), status: :see_other
  end

  def destroy
    if Ils.cancel_hold_request(current_user.ils_primary_id, params[:id])
      flash[:success] = t(".success")
    else
      flash[:error] = t(".error")
    end

    redirect_to record_items_path(
      record_id: @record.id,
      search_scope: current_search_scope
    ), status: :see_other
  end

  private

  def authorize!
    unless current_user.can_manage_hold_requests?
      redirect_to account_root_path and return
    end

    true
  end

end
