class SessionsController < ApplicationController

  def create
    return redirect_to(root_path) if params[:cancel].present?

    username = params.dig("login", "username")
    password = params.dig("login", "password")

    if username.present? && password.present?
      if Ils.authenticate_user(username, password)
        ils_user = Ils.get_user(username)
        db_user  = create_or_update_user!(ils_user)

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
    redirect_to(root_path)
  end

private

  def create_or_update_user!(ils_user)
    User.transaction do
      user = User.where(ils_primary_id: ils_user.id).first_or_initialize
      user.assign_attributes(
        ils_primary_id: ils_user.id,
        first_name:     ils_user.first_name,
        last_name:      ils_user.last_name,
        email:          ils_user.email
      )
      user.save!
      user
    end
  end

end
