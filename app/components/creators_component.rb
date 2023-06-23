class CreatorsComponent < ViewComponent::Base
  include ViewComponent::Translatable

  def initialize(creators:, item_count: 3)
    @creators = creators.reject do |c|
      c.relationships.any? { |r| r == "pbl" }
    end

    @item_count = item_count
  end

  def render?
    @creators.present?
  end

  def gnd_id_for(creator:)
    creator.authority_ids.find do |aid|
      aid.type == "GND"
    end&.id
  end

  def relationships_for(creator:)
    creator.relationships.reject do |r|
      r == "aut" || r == "oth"
    end.map do |r|
      t("code_tables.creator_relationships.#{r}", default: r)
    end.compact
  end

  def search_request_for(creator:)
    SearchEngine::SearchRequest.parse("sr[q,creator]=#{Addressable::URI.encode_component(
      gnd_id_for(creator:).presence || creator.name, Addressable::URI::CharacterClasses::UNRESERVED
    )}")
  end

end
