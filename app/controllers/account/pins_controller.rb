class Account::PinsController < Account::ApplicationController

  before_action { add_breadcrumb t("account.pins.breadcrumb"), account_pin_path }
  before_action :load_ils_user
  before_action :check_pin_set, only: [:edit, :update]
  before_action :reauthenticate!

  def show
  end

  def new
    @form = PinForm.new
  end

  def create
    @form = PinForm.new(
      params.require(:pin_form).permit(:pin)
    )

    if @form.valid? && Ils.set_user_pin(current_user.ils_primary_id, @form.pin)
      redirect_to account_pin_path, notice: t(".success_notice")
    else
      render "new", status: :unprocessable_entity
    end
  end

  def edit
    @form = PinForm.new
  end

  def update
    @form = PinForm.new(
      params.require(:pin_form).permit(:current_pin, :pin)
    )

    if @form.valid?
      if Ils.set_user_pin(current_user.ils_primary_id, @form.pin)
        redirect_to account_pin_path, notice: t(".success_notice")
      else
        redirect_to account_pin_path, error: t(".error_notice")
      end
    else
      render "edit", status: :unprocessable_entity
    end
  end

  private

  def load_ils_user
    @ils_user = current_user.ils_user(force_reload: true)
  end

  def check_pin_set
    unless @ils_user.has_pin_set?
      redirect_to new_account_pin_path
      return false
    end

    true
  end

end
