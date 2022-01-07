class PasswordResetRequestForm < ApplicationForm

  attr_accessor :user_id

  validates :user_id, presence: true

end
