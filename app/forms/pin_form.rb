class PinForm

  include ActiveModel::API

  attr_accessor :pin, :pin_confirmation

  validates :pin, presence: true, confirmation: true, length: {minimum: 4, maximum: 8}, format: {with: /\A[0-9]+\z/}

end
