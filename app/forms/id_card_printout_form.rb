class IdCardPrintoutForm < ApplicationForm

  attribute :ils_id, :string
  validates :ils_id, presence: true
  validate :validate_ils_user_exists

  def ils_user
    @ils_user ||= Ils.get_user(ils_id) if ils_id.present?
  end

  private

  def validate_ils_user_exists
    if ils_id.present? && ils_user.nil?
      errors.add(:ils_id, I18n.t("activations.errors.ils_user_not_found"))
    end
  end

end
