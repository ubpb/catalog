class Admin::ApplicationController < ApplicationController

  before_action -> { add_breadcrumb("Admin", admin_root_path) }

  before_action :authenticate!
  before_action :authorize!

  layout "admin/main"

  class NotAuthorizedError < StandardError; end

  protected

  def authenticate!
    if current_admin_user
      true
    else
      redirect_to(new_admin_session_path)
      false
    end
  end

  def authorize!
    raise NotAuthorizedError unless current_admin_user.can_access_admin?
  end

  def current_admin_user
    @current_admin_user ||= if (user_id = session[:current_admin_user_id])
      User.find_by(id: user_id)
    end
  end
  helper_method :current_admin_user

  rescue_from NotAuthorizedError do
    render "admin/unauthorized", status: :unauthorized, layout: "admin/base"
  end

end
