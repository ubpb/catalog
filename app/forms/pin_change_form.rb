class PinChangeForm
  include ActiveModel::API

  attr_accessor :current_pin
  attr_accessor :new_pin
  attr_accessor :new_pin_confirmation
  attr_accessor :pin_in_ils

  validates :current_pin, presence: true
  validates :new_pin, presence: true, confirmation: true, length: {minimum: 4, maximum: 8}
  validate :current_pin_is_correct

  def current_pin_is_correct
    if pin_in_ils != current_pin
      errors.add(:current_pin, I18n.t("account.pins.form.errors.current_pin_incorrect"))
    end
  end

end
