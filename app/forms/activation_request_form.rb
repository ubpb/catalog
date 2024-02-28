class ActivationRequestForm < ApplicationForm
  attribute :ils_id, :string
  attribute :activation_code, :string
  attribute :skip_email_validation, :boolean, default: false

  validates :ils_id, presence: true

  validate :validate_ils_user_exists
  validate :validate_ils_user_needs_activation
  validate :validate_ils_user_needs_email
  validate :validate_activation_code

  def ils_user
    if ils_id.present?
      @ils_user ||= Ils.get_user(ils_id)
    end
  end

  def skip_email_validation!
    self.skip_email_validation = true
  end

  private

  def validate_ils_user_exists
    if ils_id.present? && ils_user.nil?
      errors.add(:ils_id, I18n.t("activations.errors.ils_user_not_found"))
    end
  end

  def validate_ils_user_needs_activation
    if ils_id.present? && ils_user && !ils_user.needs_activation?
      errors.add(:ils_id, I18n.t("activations.errors.already_activated"))
    end
  end

  def validate_ils_user_needs_email
    return if skip_email_validation
    return if activation_code.present?

    if ils_id.present? && ils_user && ils_user.email.blank?
      errors.add(:ils_id, I18n.t("activations.errors.no_email"))
    end
  end

  def validate_activation_code
    if ils_id.present? &&
        activation_code.present? &&
        (user = User.find_by(ils_primary_id: ils_id)).present? &&
        user.activation_code != activation_code
      errors.add(:activation_code, I18n.t("activations.errors.invalid_activation_code"))
    end
  end

end
