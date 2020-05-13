class ApplicationController < ActionController::Base

  helper_method :current_user

  def current_user
    @current_user ||= begin
      if user_id = session[:current_user_id]
        User.find_by(id: user_id)
      end
    end
  end

  def authenticate!
    redirect_to(new_session_path) unless current_user
  end

end
