class PaginatorComponent < ViewComponent::Base
  include ViewComponent::Translatable

  def initialize(page:, per_page:, total:)
    @page     = page
    @per_page = per_page
    @total    = total

    @max_page = total.fdiv(@per_page).ceil
    @min_page = 1

    @page = @max_page if @page >= @max_page
    @page = @min_page if @page <= @min_page

    @next_page     = has_next_page?     ? @page + 1 : @page
    @previous_page = has_previous_page? ? @page - 1 : @page

    @from = @page * @per_page - @per_page + 1
    @to   = @from + @per_page - 1
    @to   = @total if @to >= @total
  end

  def has_next_page?
    @page < @max_page
  end

  def has_previous_page?
    @page > @min_page
  end

  def has_pages?
    has_next_page? || has_previous_page?
  end

  def first_page_path
    path_for(page: @min_page)
  end

  def last_page_path
    path_for(page: @max_page)
  end

  def next_page_path
    path_for(page: @next_page)
  end

  def previous_page_path
    path_for(page: @previous_page)
  end

private

  def current_uri
    @current_uri ||= Addressable::URI.parse(request.url)
  end

  def current_path
    current_uri.path.presence || ""
  end

  def current_params
    query = current_uri.query.presence || ""
    query = query.gsub(/page=\d+/, "")

    query.split("&").map(&:presence).compact
  end

  def path_for(page:)
    if (page == @min_page)
      "#{current_path}?#{current_params.join("&")}"
    else
      "#{current_path}?#{current_params.prepend("page=#{page}").join("&")}"
    end
  end

end
