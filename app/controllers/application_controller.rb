class ApplicationController < ActionController::Base

  helper_method :current_user
  helper_method :current_search_scope
  helper_method :breadcrumb

  def current_user
    @current_user ||= begin
      if user_id = session[:current_user_id]
        User.find_by(id: user_id)
      end
    end
  end

  def current_search_scope
    search_scopes = Config[:search_scopes]&.keys || []
    search_scope  = search_scopes.find{|_| _ == params[:search_scope]&.to_sym}
    search_scope || Config[:search_scopes].keys.first
  end

  def authenticate!
    unless current_user
      redirect_to(new_session_path)
      return false
    else
      return true
    end
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
