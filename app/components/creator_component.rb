class CreatorComponent < ViewComponent::Base
  include ViewComponent::Translatable

  def initialize(creator:, creator_iteration:)
    @creator = creator
    @iteration = creator_iteration
  end

  def gnd_id
    @gnd_id ||= @creator.authority_ids.find do |aid|
      aid.type == "GND"
    end&.id
  end

end
