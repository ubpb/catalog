class SessionsController < ApplicationController

  def new
    @return_uri = capture_return_uri

    if current_user
      if @return_uri.present?
        redirect_to  @return_uri
      else
        redirect_to account_root_path
      end
    end
  end

  def create
    user_id  = params.dig("login", "user_id")
    password = params.dig("login", "password")
    return_uri = session[:return_uri]

    if user_id.present? && password.present?
      if Ils.authenticate_user(user_id, password)
        ils_user = Ils.get_user(user_id)
        db_user  = User.create_or_update_from_ils_user!(ils_user)

        reset_session

        session[:current_user_id] = db_user.id
        flash[:success] = t(".success")
        
        if return_uri.present?
          redirect_to return_uri
        else
          redirect_to account_root_path
        end

        session.delete("return_uri")
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

  def capture_return_uri
    return_uri = sanitize_return_uri(params[:return_uri].presence)

    if return_uri.present?
      session[:return_uri] = return_uri
      return_uri
    end
  end  

end