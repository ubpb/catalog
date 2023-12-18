class Account::ActivationsController < Account::ApplicationController

  skip_before_action :check_activation
  layout "application"

  def show
    @form = AccountActivationForm.new
  end

  def create
    @form = AccountActivationForm.new(
      params.require(:account_activation).permit(:terms_of_use)
    )

    if @form.valid?
      if activate_account
        flash[:success] = t(".flash.success")
      else
        flash[:error] = t(".flash.error")
      end

      redirect_to account_root_path
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def activate_account
    Ils.delete_user_block(current_user.ils_primary_id, "50-GLOBAL")
  end

end
