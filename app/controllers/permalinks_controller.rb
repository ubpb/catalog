class PermalinksController < ApplicationController

  def resolve
    if permalink = Permalink.find_by(key: params[:id])
      permalink.update_column(:last_resolved_at, Time.zone.now)

      if permalink.search_request.starts_with?("{")
        # We've found an search request that was created with the old "katalog".
        # Redirect to the old "searches" path and let our compat layer handle this case.
        path = "/#{permalink.scope}/searches?search_request=#{permalink.search_request}"
        redirect_to(path, allow_other_host: true)
      else
        path  = "#{searches_path(search_scope: permalink.scope)}?#{permalink.search_request}"
        redirect_to(path, allow_other_host: true)
      end
    else
      flash[:error] = t(".flash_error")
      redirect_to(root_path)
    end
  end

  def create
    max_tries ||= 5

    key            = SecureRandom.hex(16)
    scope          = params[:scope]&.presence
    search_request = params[:search_request]&.presence

    permalink = Permalink.new(key: key, scope: scope, search_request: search_request)

    if permalink.save
      redirect_to(permalink_path(permalink))
    else
      flash[:error] = t(".flash_error")
      redirect_to(root_path)
    end
  rescue ActiveRecord::RecordNotUnique
    if (max_tries -= 1).zero?
      flash[:error] = t(".flash_error")
      redirect_to(root_path)
    else
      retry
    end
  end

  def show
    #add_breadcrumb name: "permalinks#show"

    if permalink = Permalink.find_by(key: params[:id])
      @permalink = permalink
    else
      flash[:error] = t(".flash_error")
      redirect_to(root_path)
    end
  end

end
