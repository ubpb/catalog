class SessionsController < ApplicationController

  def new
    return_to = capture_return_to

    if current_user
      if return_to.present?
        redirect_to return_to
      else
        redirect_to account_root_path
      end
    end
  end

  def create
    user_id  = params.dig("login", "user_id")
    password = params.dig("login", "password")
    return_to = session[:return_to]

    if user_id.present? && password.present?
      if Ils.authenticate_user(user_id, password)
        ils_user = Ils.get_user(user_id)
        db_user  = User.create_or_update_from_ils_user!(ils_user)

        reset_session

        session[:current_user_id] = db_user.id
        flash[:success] = t(".success")
        
        if return_to.present?
          redirect_to return_to
        else
          redirect_to account_root_path
        end

        session.delete("return_to")
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

private

  def capture_return_to
    return_to = sanitize_return_to(params[:return_to])

    if return_to.present?
      session[:return_to] = return_to
      return_to
    end
  end  

end
