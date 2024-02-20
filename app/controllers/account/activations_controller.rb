class Account::ActivationsController < Account::ApplicationController

  # Do not enforce todos for this controller if the user
  # needs activation.
  skip_before_action :enforce_todos!, if: -> do
    current_user.ils_user.needs_activation?
  end

  before_action { add_breadcrumb t("account.activations.breadcrumb"), account_activation_path }

  layout "application"

  def show
    @form = AccountActivationForm.new
  end

  def create
    unless current_user.ils_user.needs_activation?
      redirect_to account_root_path and return
    end

    @form = AccountActivationForm.new(
      params.require(:account_activation).permit(:terms_of_use)
    )

    if @form.valid?
      if activate_account
        flash[:success] = t(".flash.success")
      else
        flash[:error] = t(".flash.failure")
      end

      current_user.reload_ils_user!
      redirect_to account_root_path
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def check_activation

  end

  def activate_account
    User.transaction do
      current_user.update!(activated_at: Time.zone.now)

      unless current_user.ils_user.activate_account
        raise ActiveRecord::Rollback
      end

      Account::ActivationsMailer.onboarding_info(current_user).deliver_later

      true
    end
  end

end
