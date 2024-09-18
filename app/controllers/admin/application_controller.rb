class Admin::ApplicationController < ApplicationController

  before_action :authenticate!
  before_action -> { add_breadcrumb("Admin", admin_root_path) }


  def authenticate!
    config_username = Rails.application.credentials.registrations&.dig(:admin_username)
    config_password = Rails.application.credentials.registrations&.dig(:admin_password)

    if config_username.present? && config_password.present?
      authenticate_or_request_with_http_basic do |username, password|
        secure_password = BCrypt::Password.new(
          BCrypt::Password.create(password)
        )

        username == config_username && secure_password == config_password
      end
    else
      false
    end
  end

end
