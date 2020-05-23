class PagedOperation < Operation

  PER_PAGE_DEFAULT = 10
  PER_PAGE_MAX     = 100
  PAGE_DEFAULT     = 1

  attr_reader :per_page
  attr_reader :page

  def call(*args)
    if args.last.is_a?(Hash)
      options = args.last
      @per_page = per_page_value(options.delete(:per_page))
      @page     = page_value(options.delete(:page))
    end
  end

private

  def per_page_value(value)
    value = value.to_i
    value = (value <= 0) ? PER_PAGE_DEFAULT : value
    (value >= 100) ? PER_PAGE_MAX : value
  end

  def page_value(value)
    value = value.to_i
    (value <= 0) ? PAGE_DEFAULT : value
  end

end
