class Todo
  include ActiveModel::API
  include ActiveModel::Attributes

  attribute :key, :string
  attribute :blocking, :boolean, default: false
  attribute :title, :string
  attribute :description, :string
  attribute :action_title, :string
  attribute :action_url, :string

  validates :key, presence: true
  validates :title, presence: true
  validates :description, presence: true
  validates :action_title, presence: true
  validates :action_url, presence: true

  def blocking?
    blocking
  end

  def optional?
    !blocking?
  end

end
