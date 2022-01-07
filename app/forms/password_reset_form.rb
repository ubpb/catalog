class PasswordResetForm < ApplicationForm

  PASSWORD_FORMAT = /\A
    (?=.*\d)           # Must contain a digit
    (?=.*[a-z])        # Must contain a lower case character
    (?=.*[A-Z])        # Must contain an upper case character
    (?=.*[[:^alnum:]]) # Must contain a symbol
  /x

  attr_accessor :password, :password_confirmation

  validates :password,
    presence: true,
    confirmation: true,
    length: {minimum: 8, maximum: 30},
    format: {with: PASSWORD_FORMAT}

end
