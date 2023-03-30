class Registration < ApplicationRecord

  HASHIDS_SALT = Rails.application.credentials.registrations&.dig(:hashids_salt) || "my_default_salt".freeze
  HASHIDS_MIN_LENGTH = 8

  EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d-]+(\.[a-z\d-]+)*\.[a-z]+\z/i

  REG_TYPES = [
    "emeritus",
    "guest",
    "guest_student",
    "external",
    "external_u18"
  ].freeze

  ACADEMIC_TITLES = [
    "dr",
    "dr_dr",
    "dr_ing",
    "jprof",
    "jprof_dr",
    "pd_dr",
    "prof",
    "prof_dr",
    "prof_dr_ing"
  ].freeze

  GENDERS = [
    "male", "female", "other"
  ].freeze

  attribute :ignore_missing_email, :boolean, default: false

  validates :reg_type, inclusion: {in: REG_TYPES}
  validates :gender, inclusion: {in: GENDERS}, allow_blank: true
  validates :academic_title, inclusion: {in: ACADEMIC_TITLES}, allow_blank: true
  validates :firstname, presence: true
  validates :lastname, presence: true
  validates :birthdate, presence: true
  validates :street_address, presence: true
  validates :zip_code, presence: true
  validates :city, presence: true
  validates :terms_of_use, acceptance: true

  validate :validate_email
  validate :validate_second_address

  def hashed_id
    Hashids.new(HASHIDS_SALT, HASHIDS_MIN_LENGTH).encode(id)
  end

  def self.to_id(hashed_id)
    Hashids.new(HASHIDS_SALT, HASHIDS_MIN_LENGTH).decode(hashed_id).first
  end

  def to_param
    hashed_id
  end

  def validate_email
    errors.add(:email, :invalid) if email.present? && email !~ EMAIL_REGEX
    errors.add(:email, :blank)   if email.blank?   && !ignore_missing_email
  end

  def validate_second_address
    return unless street_address2.present? || zip_code2.present? || city2.present?

    errors.add(:street_address2, :blank) if street_address2.blank?
    errors.add(:zip_code2, :blank)       if zip_code2.blank?
    errors.add(:city2, :blank)           if city2.blank?
  end

end
