class ApplicationForm
  include ActiveModel::Model

  def persisted?
    false
  end
end
