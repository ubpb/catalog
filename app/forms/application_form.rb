class ApplicationForm
  include ActiveModel::API
  include ActiveModel::Attributes

  def persisted?
    false
  end
end
