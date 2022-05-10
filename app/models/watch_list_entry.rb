class WatchListEntry < ApplicationRecord

	# Relations
	belongs_to :watch_list

	# Validations
	validates :scope, presence: true
	validates :record_id, presence: true

end
