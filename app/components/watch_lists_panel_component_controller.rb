class WatchListsPanelComponentController < ApplicationController

  def reload
    render WatchListsPanelComponent.new(
      user: current_user,
      search_scope: params[:search_scope],
      record_id: params[:record_id]
    )
  end

  def create_watch_list
    current_user.watch_lists.create!(permitted_params)

    render WatchListsPanelComponent.new(
      user: current_user,
      search_scope: params[:search_scope],
      record_id: params[:record_id]
    )
  end

  def add_record
    watch_list   = current_user.watch_lists.find(params[:watch_list_id])
    search_scope = params[:search_scope]
    record_id    = params[:record_id]

    watch_list.entries.create(scope: search_scope, record_id: record_id)

    render WatchListsPanelComponent.new(
      user: current_user,
      search_scope: search_scope,
      record_id: record_id
    )
  end

  def remove_record
    watch_list   = current_user.watch_lists.includes(:entries).find(params[:watch_list_id])
    search_scope = params[:search_scope]
    record_id    = params[:record_id]

    watch_list.entries.find_by(
      record_id: record_id,
      scope: search_scope
    )&.destroy

    render WatchListsPanelComponent.new(
      user: current_user,
      search_scope: search_scope,
      record_id: record_id
    )
  end

private

  def permitted_params
    params.require(:watch_list).permit(:name)
  end

end
