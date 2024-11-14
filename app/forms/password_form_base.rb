module PasswordFormBase

  extend ActiveSupport::Concern

  PASSWORD_FORMAT = /\A
    (?=.*\d)           # Must contain a digit
    (?=.*[[:^alnum:]]) # Must contain a symbol
  /x

  included do
    attr_accessor :password

    validates :password,
              presence: true,
              confirmation: true,
              length: {minimum: 8, maximum: 30},
              format: {with: PASSWORD_FORMAT}
  end

end
