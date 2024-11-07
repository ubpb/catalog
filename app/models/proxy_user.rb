class ProxyUser < ApplicationRecord

  # Relations
  belongs_to :user
  belongs_to :proxy_user, class_name: "User"

  # Validations
  validates :user_id, presence: true
  validates :proxy_user_id, presence: true, uniqueness: {scope: :user_id}
  validate  :expired_at_must_be_in_the_future

  # Form attributes: not stored in the database, but used as part of the UI form.
  attribute :ils_primary_id, :string
  attribute :name, :string

  # Custom validation, to make sure the expiration date is in the future.
  def expired_at_must_be_in_the_future
    return if expired_at.blank?
    return unless expired_at < Time.zone.today

    errors.add(:expired_at, :in_the_past)
  end

end
