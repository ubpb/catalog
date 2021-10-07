class Compat::V1RecordsController < Compat::ApplicationController

  def show
    record_id = params[:id]

    if record_id.upcase.starts_with?("PAD_ALEPH") # Local record
      redirect_to(record_path(id: record_id.gsub(/PAD_ALEPH/i, ""), search_scope: "local"))
    else # CDI record
      redirect_to(record_path(id: record_id, search_scope: "cdi"))
    end
  end

end
