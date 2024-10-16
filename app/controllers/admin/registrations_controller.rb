class Admin::RegistrationsController < Admin::ApplicationController

  before_action -> { add_breadcrumb("Registrierungen", admin_registrations_path) }

  def index
    @registrations = Registration.order(created_in_alma: :asc, created_at: :desc)
    return if (query = params[:q]).blank?

    @registrations = @registrations.where(
      "firstname like :q OR lastname like :q OR id = :id", q: "%#{query}%", id: Registration.to_id(query)
    )
  end

  def new
    @registration = Registration.new
    add_breadcrumb("Sonderfall erfassen")
  end

  def create
    @registration = Registration.new(registration_params)
    add_breadcrumb("Sonderfall erfassen")

    if @registration.save
      flash[:success] = "Registrierung erfolgreich angelegt."
      redirect_to admin_registration_path(@registration)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @registration = Registration.find(Registration.to_id(params[:id]))
    add_breadcrumb("Details", admin_registration_path(@registration))
  end

  def edit
    @registration = Registration.find(Registration.to_id(params[:id]))
    add_breadcrumb("Bearbeiten", edit_admin_registration_path(@registration))
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

  def print
    @registration = Registration.find(Registration.to_id(params[:id]))

    ils_user = Ils.get_user(@registration.alma_primary_id)
    raise ActiveRecord::RecordNotFound if ils_user.nil?

    @user = User.create_or_update_from_ils_user!(ils_user)
    @user.create_activation_code!
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

  def check_duplicates
    @registration = Registration.find(Registration.to_id(params[:id]))

    names_query_string = "
      last_name~#{@registration.lastname.gsub(/\s/, "_")}* AND
      first_name~#{@registration.firstname.gsub(/\s/, "_")}* AND
      birth_date~#{@registration.birthdate.strftime("%Y-%m-%d")}
    ".gsub(/\s+/, " ").strip
    @name_duplicates = check_duplicates_in_alma(@registration, names_query_string)

    if @registration.email.present?
      email_query_string = "email~#{@registration.email}"
      @email_duplicates = check_duplicates_in_alma(@registration, email_query_string)
    end
  rescue AlmaApi::Error => e
    msg = "Error checking duplicate users in Alma [#{e.code}]: #{e.message}"
    Rails.logger.error(msg)
    @error = msg
  end

  private

  def authorize!
    super
    raise NotAuthorizedError unless current_admin_user.can_access_admin_registrations?
  end

  def check_duplicates_in_alma(registration, query_string)
    alma_users = Ils.adapter.api.get(
      "users",
      params: {
        q: query_string,
        expand: "full"
      }
    )["user"]

    if alma_users.present?
      alma_users.map do |alma_user|
        {
          primary_id: alma_user["primary_id"],
          first_name: alma_user["first_name"],
          last_name: alma_user["last_name"],
          birth_date: alma_user["birth_date"].present? ? Date.parse(alma_user["birth_date"]) : nil
        }
      end
    else
      []
    end
  end

  def registration_params
    params.require(:registration).permit(
      :terms_of_use,
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
      :city2
    )
  end

  def create_user_in_alma(registration)
    alma_user = alma_user_from_registration(registration)

    result = Ils.adapter.api.post("users", body: alma_user.to_json)
    result["primary_id"].presence
  rescue AlmaApi::Error => e
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
      force_password_change: true,
      # 50-GLOBAL is the default block for all users to mark them as "newly created in Alma".
      # The user needs to go through the "first login/activation" process to remove this block.
      user_block: [{
        block_type: {
          value: "GENERAL"
        },
        block_description: {
          value: "50-GLOBAL"
        },
        block_status: "ACTIVE",
        segment_type: "Internal"
      }]
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
    when "external_u18" then "04" # PE - Externe Benutzer
    else "04"
    end
  end

  def alma_expiry_date_from_registration(registration)
    date = case registration.user_group
    when "emeritus" then Time.zone.today + 5.years # PP - Emeriti u.im Ruhestand bef. Prof.
    when "guest" then Time.zone.today + 5.years # PG - Gast der Universität
    when "guest_student" then Time.zone.today + 2.years # PZ - Gast der Bibliothek
    when "external" then Time.zone.today + 5.years # PE - Externe Benutzer
    when "external_u18" then Time.zone.today + 5.years # PE - Externe Benutzer
    end

    date.strftime("%Y-%m-%d") if date.present?
  end

  def alma_statistical_category_from_registration(registration)
    case registration.user_group
    when "emeritus" then "12" # PP - Emeriti u.im Ruhestand bef. Prof.
    when "guest" then "13" # PG - Gast der Universität
    when "guest_student" then "03" # PZ - Gast der Bibliothek
    when "external" then "04" # PE - Externe Benutzer
    when "external_u18" then "04" # PE - Externe Benutzer
    else "04"
    end
  end
end
