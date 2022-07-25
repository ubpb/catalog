class ApplicationController < ActionController::Base

  before_action :set_robots_tag

  helper_method :current_user
  helper_method :available_search_scopes
  helper_method :current_search_scope
  helper_method :breadcrumb
  helper_method :new_search_request_path
  helper_method :show_record_path
  helper_method :rss_search_request_url
  helper_method :on_campus?

  def set_robots_tag
    response.headers["X-Robots-Tag"] = 'noindex,nofollow,noarchive,nosnippet,notranslate,noimageindex'
  end

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

  def on_campus?(ip_address = request.remote_ip)
    campus_networks = Config[:campus_networks, default: []]

    campus_networks.any? do |network|
      IPAddr.new(network) === ip_address
    end
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
    call_number.starts_with?(/\d/)
  end
  helper_method :journal_call_number?

  def mono_location(call_number, location_code)
    notation = call_number.try(:[], /\A[A-Z]{1,3}/).presence

    if location_code && notation
      LOCATION_LOOKUP_TABLE.find do |row|
        systemstellen_range = row[:systemstellen]
        standortkennziffern = row[:standortkennziffern]

        if systemstellen_range.present? && systemstellen_range.first.present? && systemstellen_range.last.present? && standortkennziffern.present?
          # Expand systemstellen and notation to 4 chars to make ruby range include? work in this case.
          justified_systemstellen_range = (systemstellen_range.first.ljust(4, "A") .. systemstellen_range.last.ljust( 4, "A"))
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

  rescue_from CanCan::AccessDenied do |e|
    flash[:error] = t("access_denied")
    redirect_to(root_url)
  end

end
