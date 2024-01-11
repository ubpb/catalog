class ProxyUser < ApplicationUser

  belongs_to :user

  validates :ils_primary_id, presence: true
  validates :label, presence: true

end
