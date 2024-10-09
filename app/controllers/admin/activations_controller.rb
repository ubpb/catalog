class Admin::ActivationsController < Admin::ApplicationController

  before_action -> { add_breadcrumb("Aktivierungen", admin_activations_path) }
  before_action :authorize!

  def authorize!
    super
    raise NotAuthorizedError unless current_admin_user.can_access_admin_activations?
  end

  def index
    redirect_to new_admin_activation_path
  end

  def new
    @form = ActivationRequestForm.new
  end

  def create
    @form = ActivationRequestForm.new(
      params.require(:activation).permit(:ils_id)
    )

    @form.skip_email_validation!

    if @form.valid? && (ils_user = @form.ils_user).present?
      user = User.create_or_update_from_ils_user!(ils_user)
      user.create_activation_code!

      redirect_to print_admin_activations_path(user)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def print
    @user = User.find(params[:user_id])
  end

end
