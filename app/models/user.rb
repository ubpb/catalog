class User < ApplicationRecord

  # Relations
  has_many :watch_lists, dependent: :destroy
  has_many :notes, dependent: :destroy

  # Validations
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :ils_primary_id, presence: true

  class << self
    def create_or_update_from_ils_user!(ils_user)
      User.transaction do
        user = User.where(ils_primary_id: ils_user.id).first_or_initialize
        user.assign_attributes(
          ils_primary_id: ils_user.id,
          expiry_date: ils_user.expiry_date,
          user_group_code: ils_user.user_group&.code,
          user_group_label: ils_user.user_group&.label,
          first_name: ils_user.first_name,
          last_name: ils_user.last_name,
          email: ils_user.email,
          force_password_change: ils_user.force_password_change
        )
        user.save!
        user
      end
    end
  end

  def name
    [first_name, last_name].map(&:presence).compact.join(" ").presence
  end

  def name_reversed
    [last_name, first_name].map(&:presence).compact.join(", ").presence
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

  def api_key
    read_attribute(:api_key) || recreate_api_key!
  end

  def recreate_api_key!
    key = SecureRandom.hex(16)
    update(api_key: key)
    key
  end

  def expires_soon?
    expiry_date.present? && expiry_date <= 40.days.from_now
  end

  def expired?
    expiry_date.present? && expiry_date <= Time.zone.now
  end

end
