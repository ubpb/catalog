class RegistrationsController < ApplicationController

  def index
    add_breadcrumb(t("registrations.new.breadcrumb"))
  end

  def new
    add_breadcrumb(t("registrations.new.breadcrumb"))

    user_group = params[:type]
    ensure_valid_user_group!(user_group)

    @registration = Registration.new
    @registration.user_group = user_group
  end

  def create
    add_breadcrumb(t("registrations.new.breadcrumb"))

    @registration = Registration.new(registration_params)

    if @registration.save
      UsersMailer.registration_created(@registration).deliver_later if @registration.email.present?

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

    authtoken = params[:authtoken]&.to_s&.gsub(".", "")&.strip.presence

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

  def registration_params
    params.require(:registration).permit(
      :user_group,
      :academic_title,
      :gender,
      :firstname,
      :lastname,
      :birthdate,
      :email,
      :street_address,
      :zip_code,
      :city,
      :street_address2,
      :zip_code2,
      :city2,
      :terms_of_use,
      :ignore_missing_email
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

  def ensure_valid_user_group!(user_group)
    registrable_user_group = Registration::REGISTRABLE_USER_GROUPS.keys.find { |t| t == user_group }

    if registrable_user_group.blank?
      flash[:error] = t("registrations.ensure_valid_user_group!.error")
      redirect_to registrations_path
      return false
    end

    true
  end

end
