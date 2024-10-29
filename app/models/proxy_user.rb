class ProxyUser < ApplicationRecord

  belongs_to :user

  validates :ils_primary_id, presence: true, uniqueness: {scope: :user_id} # rubocop:disable Rails/UniqueValidationWithoutIndex
  validates :name, presence: true

  validate :expired_at_must_be_in_the_future

  # Not stored in the database, but used to lookup the proxy user in the ILS
  attribute :barcode, :string

  def expired_at_must_be_in_the_future
    return unless expired_at.present?

    if expired_at < Time.zone.today
      errors.add(:expired_at, :in_the_past)
    end
  end

end
