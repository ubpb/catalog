class EmailChangeForm < ApplicationForm

  attr_accessor :current_password, :email

  validates :current_password, presence: true
  validates :email,
    presence: true,
    format: /\A\S+@\S+\z/

end
