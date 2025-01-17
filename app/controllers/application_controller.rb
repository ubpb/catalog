class ApplicationController < ActionController::Base

  before_action :set_locale
  before_action :load_global_message
  before_action :set_robots_tag
  before_action :logout_non_activated_user

  helper_method :current_user
  helper_method :available_search_scopes
  helper_method :current_search_scope
  helper_method :breadcrumb
  helper_method :new_search_request_path
  helper_method :show_record_path
  helper_method :rss_search_request_url
  helper_method :on_campus?

  def set_locale
    return unless helpers.locale_switching_enabled?

    locale = (cookies[:_catalog_locale] || I18n.default_locale).to_sym

    locale = if I18n.available_locales.include?(locale)
      locale
    else
      I18n.default_locale
    end

    cookies[:_catalog_locale] = {value: locale, expires: 1.year.from_now}
    I18n.locale = locale
  end

  def load_global_message
    @global_message = Admin::GlobalMessage.where(active: true).first
  end

  def extract_locale_from_accept_language_header
    request.env["HTTP_ACCEPT_LANGUAGE"]&.scan(/^[a-z]{2}/)&.first&.to_sym
  end

  def set_robots_tag
    response.headers["X-Robots-Tag"] = "noindex,nofollow,noarchive,nosnippet,notranslate,noimageindex"
  end

  def current_user
    @current_user ||= if (user_id = session[:current_user_id])
      User.find_by(id: user_id)
    end
  end

  def setup_current_user_session(user_id:)
    session[:current_user_id] = user_id
    # When a user logs in, we also setup the reauth session so the user
    # does not need to reauthenticate within the first 5 minutes of the session.
    setup_reauthentication_session
    true
  end

  def reset_current_user_session
    session[:current_user_id] = nil
    @current_user = nil
    true
  end

  def setup_reauthentication_session
    session[:reauthenticated] = true
    session[:reauthenticated_at] = Time.zone.now
    true
  end

  def reset_reauthentication_session
    session[:reauthenticated] = nil
    session[:reauthenticated_at] = nil
    true
  end

  def logout_non_activated_user
    return unless current_user&.ils_user&.needs_activation?

    reset_current_user_session
    flash[:error] = t("application.account_needs_activation_error")
    redirect_to request_activation_path and return
  end

  def authenticate!
    if authenticated?
      true
    else
      return_uri = @return_uri || sanitize_uri(request.fullpath)
      cancel_uri = sanitize_uri(request.referer) || root_path

      redirect_to(new_session_path(return_uri: return_uri, cancel_uri: cancel_uri))
      false
    end
  end

  def authenticated?
    current_user.present?
  end

  def reauthenticate!
    if authenticated? && reauthenicated?
      setup_reauthentication_session
      true
    else
      return_uri = @return_uri || sanitize_uri(request.fullpath)
      cancel_uri = sanitize_uri(request.referer) || root_path

      redirect_to(reauthentication_path(return_uri: return_uri, cancel_uri: cancel_uri))
      false
    end
  end

  def reauthenicated?
    session[:reauthenticated] == true && session[:reauthenticated_at] >= 5.minutes.ago
  end

  def ensure_xhr!
    raise ArgumentError, "This controller action expects an ajax request." unless request.xhr?
  end

  def available_search_scopes
    Config[:search_scopes]&.keys.presence || raise("No search scope configured! Please configure at least one search scope in config/search_engine.yml.")
  end

  def current_search_scope
    search_scope = available_search_scopes.find { |s| s == params[:search_scope]&.to_sym }
    search_scope || available_search_scopes.first
  end

  def on_campus?(ip_address = request.remote_ip)
    campus_networks = Config[:campus_networks, default: []]

    campus_networks.any? do |network|
      IPAddr.new(network) === ip_address
    end || Rails.env.development?
  end

  def breadcrumb
    @breadcrumb ||= []
  end

  def add_breadcrumb(label, path = nil)
    breadcrumb << {label: label, path: path}
  end

  def new_search_request_path(search_request = nil, search_scope: current_search_scope)
    path  = "#{searches_path(search_scope: search_scope)}"
    path += "?#{search_request.query_string}" if search_request.present?
    path
  end

  def show_record_path(record, search_request: nil, search_scope: current_search_scope)
    path  = "#{record_path(id: record.id, search_scope: search_scope)}"
    path += "?#{search_request.query_string}" if search_request.present?
    path
  end

  def rss_search_request_url(search_request:, search_scope: current_search_scope, format: :atom)
    url  = "#{searches_url(search_scope: search_scope, format: format)}"
    url += "?#{search_request.query_string}" if search_request.present?
    url
  end

  def journal_call_number?(call_number)
    call_number&.starts_with?(/\d/)
  end
  helper_method :journal_call_number?

  def mono_location(call_number, location_code)
    notation = call_number.try(:[], /\A[A-Z]{1,3}/).presence

    if location_code && notation
      LOCATION_LOOKUP_TABLE.find do |row|
        systemstellen_range = row[:systemstellen]
        standortkennziffern = row[:standortkennziffern]

        if systemstellen_range.present? && systemstellen_range.begin.present? && systemstellen_range.end.present? && standortkennziffern.present?
          # Expand systemstellen and notation to 4 chars to make ruby range include? work in this case.
          justified_systemstellen_range = (systemstellen_range.begin.ljust(4, "A") .. systemstellen_range.end.ljust( 4, "A"))
          justified_notation = notation.ljust(4, "A")

          standortkennziffern.include?(location_code) && justified_systemstellen_range.include?(justified_notation)
        end
      end.try do |row|
        row[:location]
      end
    end
  end

  JOURNAL_CLOSED_STOCK_THRESHOLD = "1995"

  def journal_locations(call_number, location_code, stock: nil)
    locations = []
    return locations unless journal_call_number?(call_number)

    years = (stock || []).map { |element| element.split("-") }.flatten.map { |date| date[/\d{4}/] }.compact

    if years.any? { |year| year > JOURNAL_CLOSED_STOCK_THRESHOLD } || stock.blank? || stock.any? { |s| s.strip.end_with?("-") }
      fachkennziffer = call_number.sub(/\AP\d+\//, "")[/\A\d+/]

      matching_row = LOCATION_LOOKUP_TABLE.find do |row|
        row[:standortkennziffern].try(:include?, location_code) &&
        (
          ["IEMAN", "IMT: Medien", "Zentrum für Sprachlehre"].include?(row[:location]) ||
          row[:fachkennziffern].try(:include?, fachkennziffer)
        )
      end

      locations << matching_row[:location] if matching_row
    end

    if years.any? { |year| year <= JOURNAL_CLOSED_STOCK_THRESHOLD }
      locations.unshift("Magazin")
    end

    if call_number&.starts_with?("P00")
      locations = ["Magazin J"]
    end

    locations.uniq
  end

  rescue_from IntegrationError do |e|
    Rails.logger.error [e.message, *Rails.backtrace_cleaner.clean(e.backtrace)].join($INPUT_RECORD_SEPARATOR)

    if (cause = e.cause)
      Rails.logger.error "#{$INPUT_RECORD_SEPARATOR}CAUSED BY:"
      Rails.logger.error [cause.message, *Rails.backtrace_cleaner.clean(cause.backtrace)].join($INPUT_RECORD_SEPARATOR)
    end

    if request.xhr?
      render "xhr_error", locals: {message: t("integrations.common_error_message")}, layout: false
    else
      flash[:error] = t("integrations.common_error_message")
      redirect_to root_path
    end
  end

  rescue_from User::IlsUserMissingError do |e|
    # Make sure we logoutn the user if the corresponding ILS user is missing.
    reset_current_user_session

    # Log the error
    Rails.logger.error [e.message, *Rails.backtrace_cleaner.clean(e.backtrace)].join($INPUT_RECORD_SEPARATOR)

    # Handle the error
    if request.xhr?
      render "xhr_error", locals: {message: t("integrations.ils_user_missing_error_message")}, layout: false
    else
      flash[:error] = t("integrations.ils_user_missing_error_message")
      redirect_to root_path
    end
  end

  helper_method :sanitize_uri
  def sanitize_uri(uri, query: true, fragment: true)
    if uri.present?
      uri = URI(uri)

      path = uri.path.present? ? uri.path.to_s : ""
      query = query && uri.query.present? ? "?#{uri.query}" : ""
      fragment = fragment && uri.fragment.present? ? "##{uri.fragment}" : ""

      (path + query + fragment).presence
    end
  rescue StandardError
    nil
  end

end
