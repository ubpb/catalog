class GndController < ApplicationController

  def show
    conn = Faraday.new("https://lobid.org") do |f|
      f.response :raise_error
      f.response :json
    end

    begin
      gnd_id = Addressable::URI.encode_component(params[:id], Addressable::URI::CharacterClasses::UNRESERVED)
      gnd_raw_result = conn.get("/gnd/#{gnd_id}.json").body
      @gnd_result = build_gnd_result(gnd_raw_result)
    rescue Faraday::Error
      @gnd_result = nil
    end

    if turbo_frame_request?
      render "show-modal"
    else
      render "show"
    end
  end

  private

  def build_gnd_result(gnd_raw_result)
    {
      gnd_id: get_gnd_id(gnd_raw_result),
      entity_types: get_entity_types(gnd_raw_result),
      gnd_subject_categories: get_gnd_subject_categories(gnd_raw_result),
      preferred_name: get_preferred_name(gnd_raw_result),
      variant_names: get_variant_names(gnd_raw_result),
      gender: get_gender(gnd_raw_result),
      date_of_birth: get_date_of_birth(gnd_raw_result),
      date_of_death: get_date_of_death(gnd_raw_result),
      date_of_establishment: get_date_of_establishment(gnd_raw_result),
      date_of_termination: get_date_of_termination(gnd_raw_result),
      biographical_infos: get_biographical_infos(gnd_raw_result),
      affiliations: get_affiliations(gnd_raw_result),
      professions_or_occupations: get_professions_or_occupations(gnd_raw_result),
      geographic_areas: get_geographic_areas(gnd_raw_result),
      depiction_url: get_depiction_url(gnd_raw_result),
      wikipedia_url: get_wikipedia_url(gnd_raw_result),
      succeeding_corporate_body: get_succeeding_corporate_body(gnd_raw_result),
      preceding_corporate_body: get_preceding_corporate_body(gnd_raw_result),
      place_of_business: get_place_of_business(gnd_raw_result)
    }
  end

  def get_gnd_id(gnd_raw_result)
    gnd_raw_result["gndIdentifier"]
  end

  def get_entity_types(gnd_raw_result)
    (gnd_raw_result["type"] || []).map do |type|
      type.presence&.underscore if type != "AuthorityResource"
    end.compact
  end

  def get_gnd_subject_categories(gnd_raw_result)
    (gnd_raw_result["gndSubjectCategory"] || []).map{ |a| a["label"] }
  end

  def get_preferred_name(gnd_raw_result)
    gnd_raw_result["preferredName"] || "n.n."
  end

  def get_variant_names(gnd_raw_result)
    gnd_raw_result["variantName"] || []
  end

  def get_gender(gnd_raw_result)
    gnd_raw_result["gender"]&.first&.dig("label")
  end

  def get_date_of_birth(gnd_raw_result)
    gnd_raw_result["dateOfBirth"]&.first
  end

  def get_date_of_death(gnd_raw_result)
    gnd_raw_result["dateOfDeath"]&.first
  end

  def get_date_of_establishment(gnd_raw_result)
    gnd_raw_result["dateOfEstablishment"]&.first
  end

  def get_date_of_termination(gnd_raw_result)
    gnd_raw_result["dateOfTermination"]&.first
  end

  def get_biographical_infos(gnd_raw_result)
    gnd_raw_result["biographicalOrHistoricalInformation"] || []
  end

  def get_affiliations(gnd_raw_result)
    gnd_raw_result["affiliation"]&.map{ |a| a["label"] } || []
  end

  def get_geographic_areas(gnd_raw_result)
    (gnd_raw_result["geographicAreaCode"] || []).map{ |a| a["label"] }
  end

  def get_professions_or_occupations(gnd_raw_result)
    (gnd_raw_result["professionOrOccupation"] || []).map{ |a| a["label"] }
  end

  def get_depiction_url(gnd_raw_result)
    gnd_raw_result["depiction"]&.first&.dig("thumbnail")
  end

  def get_wikipedia_url(gnd_raw_result)
    gnd_raw_result["wikipedia"]&.first&.dig("id")
  end

  def get_succeeding_corporate_body(gnd_raw_result)
    gnd_raw_result["succeedingCorporateBody"]&.first&.dig("label")
  end

  def get_preceding_corporate_body(gnd_raw_result)
    gnd_raw_result["precedingCorporateBody"]&.first&.dig("label")
  end

  def get_place_of_business(gnd_raw_result)
    gnd_raw_result["placeOfBusiness"]&.first&.dig("label")
  end

end
