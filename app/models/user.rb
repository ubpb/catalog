class User < ApplicationRecord

  # Relations
  has_many :watch_lists, dependent: :destroy
  has_many :notes, dependent: :destroy

  # Validations
  validates :ils_primary_id, presence: true

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
    @ils_user ||= Rails.cache.fetch("#{cache_key_with_version}/ils_user", expires_in: 5.minutes, force: force_reload) do
      Ils.get_user(ils_primary_id)
    end
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

  def needs_activation?
    ils_user.blocked_by?("50-GLOBAL")
  end

  def activate_account
    Ils.delete_user_block(ils_primary_id, "50-GLOBAL")
  end

end
