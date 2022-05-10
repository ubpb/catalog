class WatchListsPanelComponent < ViewComponent::Base
  include ViewComponent::Translatable

  def initialize(user:, search_scope:, record_id:)
    @user         = user
    @search_scope = search_scope
    @record_id    = record_id
    @watch_lists  = @user.watch_lists.includes(:entries)
  end

end
