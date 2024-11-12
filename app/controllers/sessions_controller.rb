class SessionsController < ApplicationController

  before_action { add_breadcrumb t("sessions.breadcrumb"), new_session_path }

  def new
    @return_uri = sanitize_return_uri(params[:return_uri])
    return unless current_user

    if @return_uri.present?
      redirect_to @return_uri
    else
      redirect_to account_root_path
    end
  end

  def create
    user_id     = params.dig("login", "user_id")
    password    = params.dig("login", "password")
    @return_uri = sanitize_return_uri(params.dig("login", "return_uri"))

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

        # Finally, redirect the user.
        flash[:success] = t(".success")
        if @return_uri.present?
          redirect_to @return_uri
        else
          redirect_to account_root_path
        end
      else
        # User failed to authenticate.
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

end
