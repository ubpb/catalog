class Account::EmailsController < Account::ApplicationController

  before_action { add_breadcrumb t("account.emails.breadcrumb"), edit_account_email_path }
  before_action :authorize

  def edit
    @form = EmailChangeForm.new
  end

  def update
    @form = EmailChangeForm.new(
      params.require(:email_change_form).permit(:current_password, :email)
    )

    if @form.valid?
      if Ils.authenticate_user(current_user.ils_primary_id, @form.current_password)
        # Form is valid and user is authenticated
        # Try to change the email.
        if Ils.set_user_email(current_user.ils_primary_id, @form.email)
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

private

  def authorize
    current_user.can_change_email?
  end

end
