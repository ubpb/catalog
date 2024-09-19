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
    ils_user = current_admin_user&.ils_user
    raise NotAuthorizedError if ils_user.nil?

    # Allow for user with role "General Administrator"
    return true if ils_user.roles.any? { |role| role.code == "26" }

    # TODO: Add more roles here

    # Raise NotAuthorizedError by default
    raise NotAuthorizedError
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
