class Admin::RegistrationsController < Admin::ApplicationController
  layout "registrations"

  before_action :authenticate!

  before_action lambda {
    add_breadcrumb("Admin", admin_registrations_path)
  }

  def index
    @registrations = Registration.order(created_in_alma: :asc, created_at: :desc)
    return if (query = params[:q]).blank?

    @registrations = @registrations.where(
      "firstname like :q OR lastname like :q OR id = :id", q: "%#{query}%", id: Registration.to_id(query)
    )
  end

  def show
    @registration = Registration.find(Registration.to_id(params[:id]))
  end

  def edit
    @registration = Registration.find(Registration.to_id(params[:id]))
  end

  def update
    @registration = Registration.find(Registration.to_id(params[:id]))

    if @registration.update(registration_params)
      flash[:success] = "Daten erfolgreich aktualisiert."
      redirect_to admin_registration_path(@registration)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    registration = Registration.find(Registration.to_id(params[:id]))
    registration.destroy
    flash[:success] = "Registrierung erfolgreich gelöscht."
    redirect_to admin_registrations_path
  end

  def confirm
    registration = Registration.find(Registration.to_id(params[:id]))

    if registration.created_in_alma?
      flash[:error] = "Registrierung wurde bereits in Alma erstellt."
      redirect_to admin_registration_path(registration)
      return
    end

    primary_alma_id = create_user_in_alma(registration)

    # rubocop:disable Rails/SkipsModelValidations
    if primary_alma_id &&
        registration.update_attribute(:alma_primary_id, primary_alma_id) &&
        registration.update_attribute(:created_in_alma, true)
      flash[:success] = "Konto erfolgreich in Alma erstellt. Ausweis kann jetzt gedruckt werden."
    else
      flash[:error] = "Konto konnte in Alma nicht erstellt werden. Bitte wiederholen Sie den Vorgang. Sollte
      der Fehler weiterhin auftreten, wenden Sie sich bitte an die IT."
    end
    # rubocop:enable Rails/SkipsModelValidations

    redirect_to admin_registration_path(registration)
  end

  private

  def authenticate!
    config_username = Rails.application.credentials.registrations&.dig(:admin_username)
    config_password = Rails.application.credentials.registrations&.dig(:admin_password)

    if config_username.present? && config_password.present?
      authenticate_or_request_with_http_basic do |username, password|
        secure_password = BCrypt::Password.new(
          BCrypt::Password.create(password)
        )

        username == config_username && secure_password == config_password
      end
    else
      false
    end
  end

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
      :ignore_missing_email
    )
  end

  def create_user_in_alma(registration)
    alma_user = alma_user_from_registration(registration)

    result = Ils.adapter.api.post("/users", body: alma_user.to_json, format: "application/json")
    result["primary_id"].presence
  rescue ExlApi::Error => e
    Rails.logger.error("Error creating user in Alma [#{e.code}]: #{e.message}")
    nil
  end

  def alma_user_from_registration(registration)
    alma_user = {
      record_type: {value: "PUBLIC"},
      account_type: {value: "INTERNAL"},
      preferred_language: {value: "de"},
      status: {value: "ACTIVE"},
      first_name: registration.firstname,
      last_name: registration.lastname,
      birth_date: registration.birthdate.strftime("%Y-%m-%d"),
      expiry_date: alma_expiry_date_from_registration(registration),
      user_group: {value: alma_user_group_from_registration(registration)},
      password: registration.birthdate.strftime("%d%m%Y"),
      force_password_change: true
    }

    if (user_title = alma_user_title_from_registration(registration))
      alma_user[:user_title] = {value: user_title}
    end

    if (gender = alma_gender_for_registration(registration))
      alma_user[:gender] = {value: gender}
    end

    if registration.email.present?
      alma_user[:contact_info] ||= {}
      alma_user[:contact_info][:email] ||= []
      alma_user[:contact_info][:email] << {
        preferred: true,
        segment_type: "Internal",
        email_address: registration.email,
        email_type: [{value: "personal"}]
      }
    end

    if registration.street_address.present? && registration.zip_code.present? && registration.city.present?
      alma_user[:contact_info] ||= {}
      alma_user[:contact_info][:address] ||= []
      alma_user[:contact_info][:address] << {
        preferred: true,
        segment_type: "Internal",
        line1: registration.street_address,
        postal_code: registration.zip_code,
        city: registration.city,
        address_type: [{value: "home"}]
      }
    end

    if registration.street_address2.present? && registration.zip_code2.present? && registration.city2.present?
      alma_user[:contact_info] ||= {}
      alma_user[:contact_info][:address] ||= []
      alma_user[:contact_info][:address] << {
        preferred: false,
        segment_type: "Internal",
        line1: registration.street_address2,
        postal_code: registration.zip_code2,
        city: registration.city2,
        address_type: [{value: "alternative"}]
      }
    end

    if (sc = alma_statistical_category_from_registration(registration))
      alma_user[:user_statistic] ||= []
      alma_user[:user_statistic] << {
        segment_type: "Internal",
        statistic_category: {value: sc},
        category_type: {value: "Benutzertyp"}
      }
    end

    # Done. Return the user object hash.
    alma_user
  end

  def alma_user_title_from_registration(registration)
    case registration.academic_title
    when "dr" then "Dr."
    when "dr_dr" then "Dr. Dr."
    when "dr_ing" then "Dr.-Ing."
    when "jprof" then "JProf."
    when "jprof_dr" then "JProf. Dr."
    when "pd_dr" then "PD Dr."
    when "prof" then "Prof."
    when "prof_dr" then "Prof. Dr."
    when "prof_dr_ing" then "Prof. Dr.-Ing."
    end
  end

  def alma_gender_for_registration(registration)
    case registration.gender
    when "male" then "MALE"
    when "female" then "FEMALE"
    when "other" then "OTHER"
    end
  end

  def alma_user_group_from_registration(registration)
    case registration.user_group
    when "emeritus" then "12" # PP - Emeriti u.im Ruhestand bef. Prof.
    when "guest" then "13" # PG - Gast der Universität
    when "guest_student" then "03" # PZ - Gast der Bibliothek
    when "external" then "04" # PE - Externe Benutzer
    when "external_u18 then" then "04" # PE - Externe Benutzer
    else "04"
    end
  end

  def alma_expiry_date_from_registration(registration)
    date = case registration.user_group
    when "emeritus" then Time.zone.today + 5.years # PP - Emeriti u.im Ruhestand bef. Prof.
    when "guest" then Time.zone.today + 5.years # PG - Gast der Universität
    when "guest_student" then Time.zone.today + 2.years # PZ - Gast der Bibliothek
    when "external" then Time.zone.today + 5.years # PE - Externe Benutzer
    when "external_u18 then" then Time.zone.today + 5.years # PE - Externe Benutzer
    end

    date.strftime("%Y-%m-%d") if date.present?
  end

  def alma_statistical_category_from_registration(registration)
    case registration.user_group
    when "emeritus" then "12" # PP - Emeriti u.im Ruhestand bef. Prof.
    when "guest" then "13" # PG - Gast der Universität
    when "guest_student" then "03" # PZ - Gast der Bibliothek
    when "external" then "04" # PE - Externe Benutzer
    when "external_u18 then" then "04" # PE - Externe Benutzer
    end
  end
end
