class PasswordChangeForm < ApplicationForm
  include PasswordFormBase

  attr_accessor :current_password

  validates :current_password, presence: true
end
