class Note < ApplicationRecord

	# Relations
	belongs_to :user

	# Validations
	validates :scope, presence: true
	validates :record_id, presence: true

end
