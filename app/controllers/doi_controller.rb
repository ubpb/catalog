class DoiController < ApplicationController

  def show
    add_breadcrumb t("doi.breadcrumb")

    @doi = params[:doi].presence
    @doi_result = LibKeyService.resolve(@doi)
  end

end
