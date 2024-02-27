class ActivationForm < ApplicationForm
  include PasswordFormBase

  attribute :terms_of_use, :boolean, default: false
  validates :terms_of_use, acceptance: true
end
