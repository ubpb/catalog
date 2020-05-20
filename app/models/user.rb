class User < ApplicationRecord

  # Validations
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :ils_primary_id, presence: true


  def name
    [first_name, last_name].map(&:presence).compact.join(" ").presence
  end

  def name_reversed
    [last_name, first_name].map(&:presence).compact.join(", ").presence
  end

end
