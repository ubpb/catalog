module PinFormBase

  extend ActiveSupport::Concern

  PIN_FORMAT = /\A[0-9]+\z/

  included do
    attr_accessor :pin

    validates :pin,
              presence: true,
              confirmation: true,
              length: {minimum: 4, maximum: 8},
              format: {with: PIN_FORMAT}
  end

end
