class PasswordResetsController < ApplicationController

  before_action :verify_password_reset_token_and_load_user, only: [:edit, :update]
  before_action :reset_session, only: [:edit, :update]

  def new
    @form = PasswordResetRequestForm.new
  end

  def create
    @form = PasswordResetRequestForm.new(
      params.require(:password_reset_request_form).permit(:user_id)
    )

    if @form.valid?
      ils_user = Ils.get_user(@form.user_id)

      if ils_user.nil?
        flash[:error] = t(".no_user_flash", user_id: @form.user_id)
        redirect_to(password_reset_request_path)
      elsif ils_user.email.blank?
        flash[:error] = t(".no_email_flash", user_id: @form.user_id)
        redirect_to(password_reset_request_path)
      elsif ils_user.needs_activation?
        flash[:error] = t(".user_needs_activation_flash", activation_link: activation_root_path)
        redirect_to(password_reset_request_path)
      else
        db_user = User.create_or_update_from_ils_user!(ils_user)
        db_user.create_password_reset_token!

        UsersMailer.password_reset_request(db_user).deliver_later

        flash[:success] = t(".success_flash", email: helpers.mask_email(ils_user.email))
        redirect_to(new_session_path)
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @form = PasswordResetForm.new
  end

  def update
    @form = PasswordResetForm.new(
      params.require(:password_reset_form).permit(:password, :password_confirmation)
    )

    if @form.valid?
      if Ils.set_user_password(@user.ils_primary_id, @form.password) && @user.clear_password_reset_token!
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

  def verify_password_reset_token_and_load_user
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

    true
  end

end
