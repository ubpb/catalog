class WatchList < ApplicationRecord

	# Relations
	belongs_to :user
	has_many :entries, class_name: "WatchListEntry", dependent: :destroy

	# Validations
	validates :name, presence: true

	def has_record_id?(record_id, search_scope:)
		self.entries.find{|entry| entry.record_id == record_id && entry.scope == search_scope.to_s}
	end

end
