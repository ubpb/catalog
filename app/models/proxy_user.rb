class ProxyUser < ApplicationRecord

  belongs_to :user

  validates :ils_primary_id, presence: true, uniqueness: {scope: :user_id} # rubocop:disable Rails/UniqueValidationWithoutIndex
  validates :name, presence: true

  # Not stored in the database, but used to lookup the proxy user in the ILS
  attribute :barcode, :string

end
