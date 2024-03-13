class RegistrationsController < ApplicationController

  layout "registrations"

  before_action -> { add_breadcrumb(t("registrations.new.breadcrumb")) }
  before_action :load_registration_request, only: [:new, :create]

  # The index page just shows some infos aout the registration process
  # and links to our homepage for further information.
  def index
  end

  def new
    @registration = Registration.new
    @registration.user_group = @registration_request.user_group
    @registration.email = @registration_request.email
  end

  def create
    @registration = Registration.new(registration_params)
    @registration.user_group = @registration_request.user_group
    @registration.email = @registration_request.email

    if @registration.save && @registration_request.destroy
      UsersMailer.registration_created(@registration).deliver_later

      session[:registration_id] = @registration.hashed_id
      flash[:success] = t("registrations.create.success")
      redirect_to registration_path(@registration)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def authorize
    @registration = Registration.find(Registration.to_id(params[:id]))
    add_breadcrumb(t("registrations.authorize.breadcrumb"), registration_path(@registration))

    return unless request.post?

    authtoken = params[:authtoken]&.to_s&.delete(".")&.strip.presence

    if authtoken && (authtoken == @registration.birthdate&.strftime("%d%m%Y"))
      session[:registration_id] = @registration.hashed_id
      redirect_to registration_path(@registration)
    else
      session[:registration_id] = nil
      flash[:error] = t("registrations.authorize.error")
      redirect_to authorize_registration_path(@registration)
    end
  end

  def show
    @registration = Registration.find(Registration.to_id(params[:id]))
    authorize_registration!(@registration)

    add_breadcrumb(t("registrations.show.breadcrumb"), registration_path(@registration))
  end

  def edit
    @registration = Registration.find(Registration.to_id(params[:id]))
    authorize_registration!(@registration)

    add_breadcrumb(t("registrations.edit.breadcrumb"), registration_path(@registration))
  end

  def update
    @registration = Registration.find(Registration.to_id(params[:id]))
    authorize_registration!(@registration)

    add_breadcrumb(t("registrations.edit.breadcrumb"), registration_path(@registration))

    if @registration.update(registration_params)
      flash[:success] = t("registrations.update.success")
      redirect_to registration_path(@registration)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  # In the previous implementation, the user group was passed as a parameter.
  # Now the user group is part of the registration request.
  # To be backwards compatible, we check the token parameter for a user group
  # and redirect if nessesary.
  def load_registration_request
    token = params[:token].presence

    if token.nil?
      redirect_to registrations_path and return
    elsif token.in?(Registration::REGISTRABLE_USER_GROUPS.keys)
      # Token is in fact a user group
      redirect_to new_registration_request_path(user_group: token) and return
    end

    @registration_request = RegistrationRequest.find_by(token: token)

    unless @registration_request
      flash[:error] = t("registrations.load_registration_request.invalid_token")
      redirect_to registrations_path and return
    end

    true
  end

  def registration_params
    params.require(:registration).permit(
      :academic_title,
      :gender,
      :firstname,
      :lastname,
      :birthdate,
      :street_address,
      :zip_code,
      :city,
      :street_address2,
      :zip_code2,
      :city2,
      :terms_of_use
    )
  end

  def authorize_registration!(registration)
    if session[:registration_id] != registration.hashed_id
      redirect_to authorize_registration_path(@registration)
      return false
    end

    if registration.created_in_alma?
      flash[:error] = t("registrations.authorize.already_created")
      redirect_to registrations_path
      return false
    end

    true
  end

end
