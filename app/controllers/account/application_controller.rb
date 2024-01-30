class Account::ApplicationController < ApplicationController

  before_action :authenticate!
  before_action :enforce_todos!

  before_action { add_breadcrumb t("account.application.breadcrumb"), account_root_path }

  layout "account/application"

  private

  def enforce_todos!
    if current_user.has_blocking_todos?
      if turbo_frame_request?
        render template: "application/turbo_frame_breakout" and return
      else
        redirect_to account_todos_path and return
      end
    end

    true
  end

end
