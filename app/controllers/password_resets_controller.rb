class PasswordResetsController < ApplicationController

  before_action :reset_session
  before_action :verify_password_reset_token, only: [:edit, :update]

  def create
    username = params.dig(:password_reset, :username)
    ils_user = Ils.get_user(username)

    if ils_user.nil?
      flash[:error] = t(".no_user_flash", user_id: username)
      redirect_to(password_reset_path)
    elsif ils_user.email.blank?
      flash[:error] = t(".no_email_flash", user_id: username)
      redirect_to(password_reset_path)
    else
      # FIXME: Make masked emails work with Alma implementation system
      # Should be removed later.
      ils_user.attributes[:email] = ils_user.email.gsub("SCRUBBED_", "")

      db_user = User.create_or_update_from_ils_user!(ils_user)
      db_user.create_password_reset_token!

      PasswordResetsMailer.notify_user(db_user).deliver_later

      flash[:success] = t(".success_flash", email: helpers.mask_email(ils_user.email))
      redirect_to(new_session_path)
    end
  end

  def edit
    @reset_password_form = ResetPasswordForm.new
  end

  def update
    @reset_password_form = ResetPasswordForm.new(
      params.require(:reset_password_form).permit(:password, :password_confirmation)
    )

    if @reset_password_form.valid?
      if Ils.set_user_password(@user.ils_primary_id, @reset_password_form.password) #&& @user.clear_password_reset_token!
        flash[:success] = t(".success_flash")
        redirect_to(new_session_path)
      else
        flash[:error] = t(".error_flash")
        redirect_to(new_session_path)
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

private

  def verify_password_reset_token
    if (@token = params[:token]).blank?
      # Should not happen due to routes definition but we test anyway to be extra safe
      flash[:error] = t("password_resets.verify_token.no_token")
      redirect_to(new_session_path) and return
    end

    @user = User.find_by(password_reset_token: @token)

    if @user.blank?
      flash[:error] = t("password_resets.verify_token.no_user")
      redirect_to(new_session_path) and return
    elsif @user.password_reset_token_created_at + 6.hours <= Time.zone.now
      flash[:error] = t("password_resets.verify_token.token_to_old")
      redirect_to(new_session_path) and return
    end

    return true
  end

end
