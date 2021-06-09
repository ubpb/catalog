class ApplicationController < ActionController::Base

  helper_method :current_user
  helper_method :available_search_scopes
  helper_method :current_search_scope
  helper_method :breadcrumb
  helper_method :new_search_request_path

  def current_user
    @current_user ||= begin
      if user_id = session[:current_user_id]
        User.find_by(id: user_id)
      end
    end
  end

  def available_search_scopes
    Config[:search_scopes]&.keys.presence || raise("No search scope configured! Please configure at least one search scope in config/search_engine.yml.")
  end

  def current_search_scope
    search_scope  = available_search_scopes.find{|_| _ == params[:search_scope]&.to_sym}
    search_scope || available_search_scopes.first
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

  def new_search_request_path(search_request = nil, options = {})
    search_scope = options[:search_scope] || current_search_scope

    path  = "#{searches_path(search_scope: search_scope)}"
    path += "?#{search_request.query_string}" if search_request.present?
    path
  end

  rescue_from IntegrationError do |e|
    Rails.logger.error [e.message, *Rails.backtrace_cleaner.clean(e.backtrace)].join($/)

    if cause = e.cause
      Rails.logger.error "#{$/}CAUSED BY:"
      Rails.logger.error [cause.message, *Rails.backtrace_cleaner.clean(cause.backtrace)].join($/)
    end

    unless request.xhr?
      flash[:error] = t("integrations.common_error_message")
      redirect_to root_path
    else
      render "xhr_error", locals: {message: t("integrations.common_error_message")}, layout: false
    end
  end

end
