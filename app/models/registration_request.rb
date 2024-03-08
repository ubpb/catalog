class RegistrationRequest < ApplicationRecord

  validates :user_group, inclusion: {in: Registration::REGISTRABLE_USER_GROUPS.keys}
  validates :email, presence: true, format: {with: Registration::EMAIL_REGEX}

  def create_token
    update(token: "#{SecureRandom.hex(16)}#{id}")
  end

end
