class AvailabilitiesController < ApplicationController

  def index
    availabilities = Ils.get_availabilities(clean_record_ids)

    respond_to do |format|
      format.json do
        case params[:mode]
        when /badge/i then
          render json: badge_result(availabilities)
        else
          render json: full_result(availabilities)
        end
      end
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

  def calculated_availability(availabilities)
    if availabilities[:availabilities].any?{|a| a[:availability] == "available"}
      "available"
    elsif availabilities[:availabilities].any?{|a| a[:availability] == "restricted"}
      "restricted"
    else
      "unavailable"
    end
  end

  def full_result(availabilities)
    availabilities.map do |availabilities|
      {
        record_id: availabilities[:record_id],
        #availabilities: availabilities,
        html_content: render_to_string(
          partial: "availabilities/full",
          formats: :html,
          locals: {availabilities: availabilities}
        )
      }
    end
  end

  def badge_result(availabilities)
    availabilities.map do |availabilities|
      availability = calculated_availability(availabilities)

      {
        record_id: availabilities[:record_id],
        #availability: availability,
        html_content: render_to_string(
          partial: "availabilities/badge",
          formats: :html,
          locals: {availability: availability}
        )
      }
    end
  end

end
