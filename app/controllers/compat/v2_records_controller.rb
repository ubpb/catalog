class Compat::V2RecordsController < Compat::ApplicationController

  def show
    search_scope = params[:search_scope]
    record_id    = params[:id]

    case search_scope
    when "primo_central"
      redirect_to(record_path(id: record_id, search_scope: "cdi"))
    else
      redirect_to(record_path(id: record_id, search_scope: "local"))
    end
  end

end
