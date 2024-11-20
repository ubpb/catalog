class Admin::SessionsController < Admin::ApplicationController

  before_action { add_breadcrumb t("sessions.breadcrumb.login"), new_admin_session_path }

  skip_before_action :authenticate!, only: [:new, :create]
  skip_before_action :authorize!

  layout "admin/base"

  def new
    redirect_to admin_root_path if current_admin_user
  end

  def create
    user_id  = params.dig("login", "user_id")
    password = params.dig("login", "password")

    if user_id.present? && password.present?
      if Ils.authenticate_user(user_id, password)
        ils_user = Ils.get_user(user_id)

        db_user  = User.create_or_update_from_ils_user!(ils_user)
        db_user.reload_ils_user!

        session[:current_admin_user_id] = db_user.id

        redirect_to admin_root_path
      else
        flash[:error] = "Fehler bei der Anmeldung. Bitte überprüfen Sie Ihre Eingaben."
        render :new, status: :unprocessable_entity
      end
    else
      redirect_to new_admin_session_path
    end
  end

  def destroy
    session[:current_admin_user_id] = nil
    redirect_to(root_path, status: :see_other)
  end

end
