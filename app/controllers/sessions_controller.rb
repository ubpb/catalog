class SessionsController < ApplicationController

  before_action :setup_return_uri
  before_action :setup_cancel_uri

  def new
    add_breadcrumb t("sessions.breadcrumb.login"), new_session_path

    redirect_to @return_uri if authenticated?
  end

  def create
    add_breadcrumb t("sessions.breadcrumb.login"), new_session_path

    redirect_to @return_uri and return if authenticated?

    user_id  = params.dig("login", "user_id")
    password = params.dig("login", "password")

    if user_id.present? && password.present?
      if Ils.authenticate_user(user_id, password)
        # Load user from ILS.
        ils_user = Ils.get_user(user_id)

        # Check if the user needs activation and redirect to activation page
        # if needed.
        if ils_user.needs_activation?
          flash[:error] = t(".user_needs_activation_flash", activation_link: activation_root_path)
          redirect_to new_session_path and return
        end

        # The user has authenticated successfully and does not need activation.
        # Make sure to create or update the local user record if it does not exist yet.
        db_user = User.create_or_update_from_ils_user!(ils_user)

        # Login user
        setup_current_user_session(user_id: db_user.id)

        # Redirect the user after login
        flash[:success] = t(".success")
        redirect_to @return_uri
      else
        # Login failed. Infom the user.
        flash[:error] = t(".error")
        render :new, status: :unprocessable_entity
      end
    else
      redirect_to(new_session_path(return_uri: @return_uri))
    end
  end

  def destroy
    reset_current_user_session
    flash[:success] = t(".success")
    redirect_to(root_path, status: :see_other)
  end

  def reauth
    add_breadcrumb t("sessions.breadcrumb.reauth"), reauthentication_path

    # Reauthentication is only possible if the user is logged in.
    authenticate! or return

    # The reauth form was submitted.
    if request.post?
      password = params.dig("reauth", "password")

      if password.present? && Ils.authenticate_user(current_user.ils_primary_id, password)
        setup_reauthentication_session
        redirect_to @return_uri
      else
        flash[:error] = t(".error")
        render :reauth, status: :unprocessable_entity
      end
    end
  end

  private

  def setup_return_uri
    @return_uri = sanitize_uri(params[:return_uri]) || account_root_path
  end

  def setup_cancel_uri
    @cancel_uri = sanitize_uri(params[:cancel_uri]) || root_path
  end

end
