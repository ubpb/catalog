class User < ApplicationRecord

  # Relations
  has_many :watch_lists, dependent: :destroy
  has_many :notes, dependent: :destroy
  has_many :proxy_users, dependent: :destroy

  # Validations
  validates :ils_primary_id, presence: true

  # Custom error classes
  class IlsUserMissingError < StandardError; end

  class << self

    def create_or_update_from_ils_user!(ils_user)
      User.transaction do
        user = User.where(ils_primary_id: ils_user.id).first_or_initialize
        user.ils_primary_id = ils_user.id
        user.save!
        user
      end
    end

  end

  def ils_user(force_reload: false)
    # Load the ILS user from the cache or fetch it from the ILS in case of a cache miss or if we want to force a reload.
    ils_user = Rails.cache.fetch("#{cache_key_with_version}/ils_user", expires_in: 5.minutes, force: force_reload) do
      Ils.get_user(ils_primary_id)
    end

    # For any user instance there must always be an ILS user.
    # If there is none, we raise a specific error. This error should be caught and handled
    # in the application_controller.
    raise IlsUserMissingError if ils_user.nil?

    # Return the ILS user
    ils_user
  end

  def reload_ils_user!
    ils_user(force_reload: true)
  end

  def create_password_reset_token!
    token = "#{SecureRandom.hex(16)}#{id}"
    update(
      password_reset_token: token,
      password_reset_token_created_at: Time.zone.now
    )
    token
  end

  def clear_password_reset_token!
    update(
      password_reset_token: nil,
      password_reset_token_created_at: nil
    )
  end

  def create_activation_token!
    token = "#{SecureRandom.hex(16)}#{id}"
    update(
      activation_token: token,
      activation_token_created_at: Time.zone.now
    )
    token
  end

  def clear_activation_token!
    update(
      activation_token: nil,
      activation_token_created_at: nil
    )
  end

  def create_activation_code!
    code = SecureRandom.hex(4).downcase
    update(activation_code: code)
    code
  end

  def clear_activation_code!
    update(activation_code: nil)
  end

  def api_key
    read_attribute(:api_key) || recreate_api_key!
  end

  def recreate_api_key!
    key = SecureRandom.hex(16)
    update(api_key: key)
    key
  end

  def todos
    return @todos if @todos.present?

    @todos = []

    # Expired / exires soon
    if ils_user.expired?
      @todos << Todo.new(
        key: :expired,
        blocking: true,
        title: I18n.t("todos.expired.title"),
        description: I18n.t("todos.expired.description"),
        action_title: nil,
        action_url: nil
      )
    elsif ils_user.expires_soon?
      @todos << Todo.new(
        key: :expires_soon,
        blocking: false,
        title: I18n.t("todos.expires_soon.title"),
        description: I18n.t("todos.expires_soon.description", date: I18n.l(ils_user.expiry_date)),
        action_title: nil,
        action_url: nil
      )
    end

    # Needs password change
    if ils_user.needs_password_change?
      @todos << Todo.new(
        key: :password_change,
        blocking: true,
        title: I18n.t("todos.password_change.title"),
        description: I18n.t("todos.password_change.description"),
        action_title: I18n.t("todos.password_change.action_title"),
        action_url: Rails.application.routes.url_helpers.edit_account_password_path
      )
    end

    # Needs PIN setup
    unless ils_user.has_pin_set?
      @todos << Todo.new(
        key: :set_pin,
        blocking: false,
        title: I18n.t("todos.set_pin.title"),
        description: I18n.t("todos.set_pin.description"),
        action_title: I18n.t("todos.set_pin.action_title"),
        action_url: Rails.application.routes.url_helpers.new_account_pin_path
      )
    end

    @todos
  end

  def has_todos?
    todos.any?
  end

  def blocking_todos
    todos.select(&:blocking?)
  end

  def has_blocking_todos?
    blocking_todos.any?
  end

  def optional_todos
    todos.select(&:optional?)
  end

  def has_optional_todos?
    optional_todos.any?
  end

  def can_change_email?
    !has_blocking_todos? &&
      ils_user.user_group&.code != "01" && # No PS
      ils_user.user_group&.code != "02"    # No PA
  end

  def can_manage_hold_requests?
    !has_blocking_todos?
  end

  def can_manage_notes?
    !has_blocking_todos?
  end

  def can_manage_watch_lists?
    !has_blocking_todos?
  end

  def can_create_closed_stack_orders?
    !has_blocking_todos?
  end

  def can_show_id_card?
    !has_blocking_todos?
  end

  # Controls who has genral access to the admin interface.
  # See below for more specific permissions on admin interface features.
  #
  # Codes are listed here:
  # https://developers.exlibrisgroup.com/alma/apis/docs/xsd/rest_user.xsd/?tags=GET#user_role
  def can_access_admin?
    # General System Administrator
    ils_user.roles.any? { |role| role.code == "26" } ||
      # Circulation Desk Operator
      ils_user.roles.any? { |role| role.code == "32" } ||
      # Circulation Desk Operator - Limited
      ils_user.roles.any? { |role| role.code == "299" }
  end

  def can_access_admin_registrations?
    can_access_admin?
  end

  def can_access_admin_activations?
    can_access_admin?
  end

  def can_access_admin_global_message?
    can_access_admin? &&
      # General System Administrator
      ils_user.roles.any? { |role| role.code == "26" }
  end

  def can_access_admin_id_card_printouts?
    can_access_admin?
  end

end
