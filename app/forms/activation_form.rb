class ActivationForm < ApplicationForm

  include PasswordFormBase
  include PinFormBase

  attribute :terms_of_use, :boolean, default: false
  validates :terms_of_use, acceptance: true

end
