class Permalink < ApplicationRecord

	# Validations
	validates :key, presence: true, format: { with: /\A[a-zA-Z0-9]+\z/ }, uniqueness: true
  validates :scope, presence: true
  validates :search_request, presence: true

  def to_param
    key
  end

end
