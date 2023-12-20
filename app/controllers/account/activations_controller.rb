class Account::ActivationsController < Account::ApplicationController

  layout "application"

  def show
    @form = AccountActivationForm.new
  end

  def create
    @form = AccountActivationForm.new(
      params.require(:account_activation).permit(:terms_of_use)
    )

    if @form.valid?
      if current_user.activate_account
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

  # @override Account::ApplicationController#check_activation
  def check_activation
    redirect_to account_root_path unless current_user.needs_activation?
  end

end
