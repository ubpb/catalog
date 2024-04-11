class LinkResolverController < ApplicationController

  def show
    add_breadcrumb t("link_resolver.breadcrumb")

    # Check Open URL against Alma link Resolver if Open URL params present
    # in the request.
    @result = AlmaLinkResolverService.resolve(request.fullpath) # TODO: user_ip ?
  end

end
