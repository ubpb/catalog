class Admin::GlobalMessage < ApplicationRecord

  STYLES = %w[info success warning danger].freeze

  validates :active, inclusion: {in: [true, false]}
  validates :style, presence: true, inclusion: {in: STYLES}

end
