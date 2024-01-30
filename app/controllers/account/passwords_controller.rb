class Account::PasswordsController < Account::ApplicationController

  # Do not enforce todos for this controller if the user
  # needs to change the password.
  skip_before_action :enforce_todos!, if: -> do
    current_user.ils_user.needs_password_change?
  end

  before_action { add_breadcrumb t("account.passwords.breadcrumb"), edit_account_password_path }

  layout "application"

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
        else
          flash[:error] = t(".error")
        end

        redirect_to account_profile_path
      else
        @form.errors.add(:current_password, t(".current_password_is_wrong"))
        render :edit, status: :unprocessable_entity
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

end
