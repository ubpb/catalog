class AvailabilitiesController < ApplicationController

  def index
    availabilities = Ils.get_availabilities(clean_record_ids)

    respond_to do |format|
      format.json {
        render json: get_availabilities_result(availabilities)
      }
    end
  end

private

  def clean_record_ids
    (params[:record_ids] || "")
      .split(",")
      .map(&:strip)
      .map(&:presence)
      .compact
  end

  def get_availabilities_result(availabilities)
    availabilities.map do |availabilities|
      {
        availabilities: availabilities,
        html_content: render_to_string(
          partial: "availabilities/availabilities",
          formats: :html,
          locals: {availabilities: availabilities}
        )
      }
    end
  end

end
