class Api::V1::ApplicationController < ApplicationController

  rescue_from ActionController::UnknownFormat do
    head :not_found
  end

  def current_user
    @current_user ||= begin
      if api_key = (request.headers["api-key"] || params[:api_key] || params[:access_token]).presence
        User.find_by(api_key: api_key)
      end
    end
  end

  def authenticate!
    head :unauthorized unless current_user
  end

end
