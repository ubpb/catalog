class LinkResolverController < ApplicationController

  def show
    add_breadcrumb t("link_resolver.breadcrumb")

    # Check Open URL against Alma link Resolver if Open URL params present
    # in the request.
    @result = AlmaLinkResolverService.resolve(request.fullpath) # TODO: user_ip ?

    # Check if we have an MMS-ID and try to load the record from our search index.
    mms_id = @result&.context&.mms_id
    @record = SearchEngine[:local].get_record(mms_id) if mms_id
  end

end
