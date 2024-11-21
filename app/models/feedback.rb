class Feedback

  include ActiveModel::Model
  include ActiveModel::Serializers::JSON

  EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d-]+(\.[a-z\d-]+)*\.[a-z]+\z/i

  TYPES = [
    "general",
    "loan_question",
    "broken_link",
    "missing_media"
  ].freeze

  attr_accessor :user_id, :firstname, :lastname, :email
  attr_accessor :type, :record_scope, :record_id, :record_title, :message

  def attributes=(hash)
    hash.each do |key, value|
      send("#{key}=", value)
    end
  end

  def attributes
    {
      "user_id" => nil,
      "firstname" => nil,
      "lastname" => nil,
      "email" => nil,
      "type" => nil,
      "record_scope" => nil,
      "record_id" => nil,
      "record_title" => nil,
      "message" => nil
    }
  end

  validates :firstname, presence: true
  validates :lastname, presence: true
  validates :email, presence: true

  validates :type, presence: true
  validates :message, presence: true

  validate :validate_email

  def validate_email
    errors.add(:email, :invalid) if email.present? && email !~ EMAIL_REGEX
    errors.add(:email, :blank)   if email.blank?
  end

end
