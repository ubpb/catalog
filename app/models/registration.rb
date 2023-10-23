class Registration < ApplicationRecord

  HASHIDS_SALT = Rails.application.credentials.registrations&.dig(:hashids_salt) || "my_default_salt".freeze
  HASHIDS_MIN_LENGTH = 8

  EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d-]+(\.[a-z\d-]+)*\.[a-z]+\z/i

  USER_GROUPS = {
    "guest":         {can_register: true},
    "guest_student": {can_register: true},
    "external":      {can_register: true},
    "external_u18":  {can_register: true},
    "emeritus":      {can_register: true},
    "student":       {can_register: false},
    "employee":      {can_register: false}
  }.with_indifferent_access.freeze

  REGISTRABLE_USER_GROUPS = USER_GROUPS.select { |_, data| data[:can_register] }.freeze

  NON_REGISTRABLE_USER_GROUPS = USER_GROUPS.reject { |_, data| data[:can_register] }.freeze

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

  before_validation :cleanup_attributes

  attribute :ignore_missing_email, :boolean, default: false

  validates :user_group, inclusion: {in: REGISTRABLE_USER_GROUPS.keys}
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
  validate :validate_u18_in_context_of_birthdate

  def cleanup_attributes
    cleaned_attributes = StripAttributes.strip(self, collapse_spaces: true).attributes

    cleaned_attributes["email"] = cleaned_attributes["email"]&.downcase

    self.attributes = cleaned_attributes
  end

  def hashed_id
    Hashids.new(HASHIDS_SALT, HASHIDS_MIN_LENGTH).encode(id)
  end

  def self.to_id(hashed_id)
    Hashids.new(HASHIDS_SALT, HASHIDS_MIN_LENGTH).decode(hashed_id).first
  rescue Hashids::InputError
    nil
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

  def validate_u18_in_context_of_birthdate
    return unless user_group == "external_u18" && birthdate.present? && birthdate < 18.years.ago

    errors.add(:birthdate, :u18_group_but_over_18)
  end

  def is_too_young?
    birthdate.blank? || birthdate >= 16.years.ago
  end

end
