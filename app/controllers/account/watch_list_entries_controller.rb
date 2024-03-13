class Account::WatchListEntriesController < Account::ApplicationController

  before_action :load_watch_list

  def destroy
    entry = @watch_list.entries.find(params[:id])

    if entry.destroy
      flash[:success] = t(".success")
    else
      flash[:error] = t(".error")
    end

    redirect_to account_watch_list_path(@watch_list), status: :see_other
  end

  private

  def load_watch_list
    @watch_list = current_user.watch_lists.find(params[:watch_list_id])
  end

end
