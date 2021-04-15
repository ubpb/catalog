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

  def ensure_xhr!
    raise ArgumentError, "This controller action expects an ajax request." unless request.xhr?
  end

  def breadcrumb
    @breadcrumb ||= []
  end

  def add_breadcrumb(label, path)
    breadcrumb << {label: label, path: path}
  end

  rescue_from IntegrationError do |e|
    # TODO: Report such errors
    Rails.logger.error [e.message, *e.backtrace].join($/)

    unless request.xhr?
      flash[:error] = t("integrations.common_error_message")
      redirect_to root_path
    else
      render "xhr_error", locals: {message: t("integrations.common_error_message")}, layout: false
    end
  end

end
