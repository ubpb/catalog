class SessionsController < ApplicationController

  def new
    @return_uri = sanitize_return_uri(params[:return_uri])

    if current_user
      if @return_uri.present?
        redirect_to @return_uri
      else
        redirect_to account_root_path
      end
    end
  end

  def create
    user_id     = params.dig("login", "user_id")
    password    = params.dig("login", "password")
    @return_uri = sanitize_return_uri(params.dig("login", "return_uri"))

    if user_id.present? && password.present?
      if Ils.authenticate_user(user_id, password)
        ils_user = Ils.get_user(user_id)

        if ils_user.needs_activation?
          flash[:error] = t(".user_needs_activation_flash", activation_link: activation_root_path)
          redirect_to new_session_path and return
        end

        db_user = User.create_or_update_from_ils_user!(ils_user)
        # Make sure we have the latest data from the ILS inside the user object.
        # because the ils user data is cached and we want the new login to reset that cache.
        db_user.reload_ils_user!

        reset_session

        session[:current_user_id] = db_user.id
        flash[:success] = t(".success")

        if @return_uri.present?
          redirect_to @return_uri
        else
          redirect_to account_root_path
        end
      else
        flash[:error] = t(".error")
        render :new, status: :unprocessable_entity
      end
    else
      redirect_to(new_session_path(return_uri: @return_uri))
    end
  end

  def destroy
    reset_session
    flash[:success] = t(".success")
    redirect_to(root_path, status: :see_other)
  end

end
