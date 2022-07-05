class Account::PasswordsController < Account::ApplicationController

  before_action { add_breadcrumb t("account.passwords.breadcrumb"), account_profile_path }

  def edit
    @form = PasswordChangeForm.new
  end

  def update
    @form = PasswordChangeForm.new(
      params.require(:password_change_form).permit(:current_password, :password, :password_confirmation)
    )

    if @form.valid?
      if Ils.authenticate_user(current_user.ils_primary_id, @form.current_password)
        # Form is valid and user is authenticated
        # Try to change the password.
        if Ils.set_user_password(current_user.ils_primary_id, @form.password)
          flash[:success] = t(".success")
          redirect_to account_profile_path
        else
          flash[:error] = t(".error")
          redirect_to account_profile_path
        end
      else
        @form.errors.add(:current_password, t(".current_password_is_wrong"))
        render :edit, status: :unprocessable_entity
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

end
