class AccountActivationForm
  include ActiveModel::API
  include ActiveModel::Attributes

  attribute :terms_of_use, :boolean, default: false

  validates :terms_of_use, acceptance: true

end
