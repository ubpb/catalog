class RegistrationRequestsController < ApplicationController

  layout "registrations"

  before_action -> { add_breadcrumb(t("registrations.new.breadcrumb")) }

  def new
    user_group = params[:user_group]
    ensure_valid_user_group!(user_group)

    @registration_request = RegistrationRequest.new(user_group: user_group)
  end

  def create
    @registration_request = RegistrationRequest.new(
      params.require(:registration_request).permit(:user_group, :email)
    )

    if @registration_request.save && @registration_request.create_token
      UsersMailer.registration_request(@registration_request).deliver_later
      flash[:success] = t(".success", email: @registration_request.email)
      redirect_to registrations_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def ensure_valid_user_group!(user_group)
    registrable_user_group = Registration::REGISTRABLE_USER_GROUPS.keys.find { |t| t == user_group }

    if registrable_user_group.blank?
      flash[:error] = t("registration_requests.ensure_valid_user_group.error")
      redirect_to registrations_path and return
    end

    true
  end

end
