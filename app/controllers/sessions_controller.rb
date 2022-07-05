class SessionsController < ApplicationController

  def new
    redirect_to account_root_path if current_user
  end

  def create
    user_id  = params.dig("login", "user_id")
    password = params.dig("login", "password")

    if user_id.present? && password.present?
      if Ils.authenticate_user(user_id, password)
        ils_user = Ils.get_user(user_id)
        db_user  = User.create_or_update_from_ils_user!(ils_user)

        reset_session

        session[:current_user_id] = db_user.id
        flash[:success] = t(".success")
        redirect_to(account_root_path)
      else
        flash[:error] = t(".error")
        render :new, status: :unprocessable_entity
      end
    else
      redirect_to(new_session_path)
    end
  end

  def destroy
    reset_session
    flash[:success] = t(".success")
    redirect_to(root_path, status: :see_other)
  end

end
