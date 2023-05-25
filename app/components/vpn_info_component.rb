class VpnInfoComponent < ViewComponent::Base
  include ViewComponent::Translatable

  def initialize(link_class: "", text_class: "")
    @link_class = link_class
    @text_class = text_class
  end

  def render?
    !helpers.on_campus?
  end

end
