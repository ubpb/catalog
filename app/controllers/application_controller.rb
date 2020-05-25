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

  rescue_from IntegrationError do |e|
    # TODO: Log/Report such errors
    unless request.xhr?
      flash[:error] = t("integrations.common_error_message")
      redirect_to root_path
    else
      render "xhr_error", locals: {message: t("integrations.common_error_message")}, layout: false
    end
  end

end
