class Account::WatchListsController < Account::ApplicationController

  before_action { add_breadcrumb t("account.watch_lists.breadcrumb"), account_watch_lists_path }

  def index
    @watch_lists = current_user.watch_lists
  end

  def new
    @watch_list = current_user.watch_lists.new
    add_breadcrumb t("account.watch_lists.new.breadcrumb")
  end

  def create
    @watch_list = current_user.watch_lists.new(permitted_params)

    if @watch_list.save
      flash[:success] = t(".success")
      redirect_to account_watch_lists_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @watch_list = current_user.watch_lists.includes(:entries).find(params[:id])

    # For each entry on the watch list try to resolve a record for display.
    # This might fail, because records may be removed from the index
    # after it has been placed on the watch list. For this cases we mark
    # the record as :deleted
    @resolved_entries = @watch_list.entries.map do |entry|
      scope = entry.scope.to_sym
      next unless available_search_scopes.include?(scope)

      if record = SearchEngine[scope].get_record(entry.record_id)
        {entry: entry, record: record}
      else
        {entry: entry, record: :deleted}
      end
    end.compact

    add_breadcrumb @watch_list.name
  end

  def edit
    @watch_list = current_user.watch_lists.find(params[:id])
    add_breadcrumb t("account.watch_lists.edit.breadcrumb")
  end

  def update
    @watch_list = current_user.watch_lists.find(params[:id])

    if @watch_list.update(permitted_params)
      flash[:success] = t(".success")
      redirect_to account_watch_list_path(@watch_list)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @watch_list = current_user.watch_lists.find(params[:id])

    if @watch_list.destroy
      flash[:success] = t(".success")
    else
      flash[:error] = t(".error")
    end

    redirect_to account_watch_lists_path
  end

private

  def permitted_params
    params.require(:watch_list).permit(
      :name, :description
    )
  end

end
