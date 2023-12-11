class PinForm
  include ActiveModel::API

  attr_accessor :pin
  attr_accessor :pin_confirmation
  attr_accessor :current_pin

  validates :pin, presence: true, confirmation: true, length: {minimum: 4, maximum: 8}, format: {with: /\A[0-9]+\z/}

end
