class RegistrationsController < ApplicationController

  def index; end

  def new
    reg_type = ensure_valid_reg_type!

    @registration = Registration.new
    @registration.reg_type = reg_type

    add_breadcrumb(t("registrations.new.breadcrumb"), registrations_path)
  end

  def create
    @registration = Registration.new(registration_params)

    add_breadcrumb(t("registrations.new.breadcrumb"), registrations_path)

    if @registration.save
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
      :reg_type,
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
      :terms_of_use
    )
  end

  def authorize_registration!(registration)
    if session[:registration_id] != registration.hashed_id
      redirect_to authorize_registration_path(@registration)
      return false
    end

    true
  end

  def ensure_valid_reg_type!
    reg_type = Registration::REG_TYPES.find { |t| t == params[:type] }

    if reg_type.blank?
      redirect_to registrations_path
      nil
    end

    reg_type
  end

end
