module ApplicationHelper

  def active_when(regexp_path_or_boolean)
    if regexp_path_or_boolean.is_a?(Regexp)
      regexp = regexp_path_or_boolean
      request.path =~ regexp ? "active" : ""
    elsif regexp_path_or_boolean.is_a?(String)
      path = regexp_path_or_boolean
      request.path == path ? "active" : ""
    else
      bool = regexp_path_or_boolean
      bool == true ? "active" : ""
    end
  end

  def mask_email(email_string)
    email_string.gsub(/(?<=.)[^@\n](?=[^@\n]*?[^@\n]@)|(?:(?<=@.)|(?!^)\G(?=[^@\n]*$)).(?=.*[^@\n]\.)/, "*")
  end

  def optional_value(optional_value, default: nil, &block)
    value = optional_value.presence || default.presence

    if block_given?
      capture(value, &block) if value
    else
      value if value
    end
  end

  def aggregation_label(aggregation)
    t(
      "searches.aggregations.#{current_search_scope}.#{aggregation.name.underscore}.label",
      default: [
        "searches.aggregations.default.#{aggregation.name.underscore}.label".to_sym,
        aggregation.name
      ]
    )
  end

  def aggregation_value(aggregation, value)
    t(
      "searches.aggregations.#{current_search_scope}.#{aggregation.name.underscore}.values.#{value.underscore}",
      default: [
        "searches.aggregations.default.#{aggregation.name.underscore}.values.#{value.underscore}".to_sym,
        value
      ]
    )
  end

  def shelf_finder_enabled?
    Config[:shelf_finder, :enabled, default: false]
  end

  def color_mode_enabled?
    Config[:color_mode, :enabled, default: false]
  end

  def locale_switching_enabled?
    Config[:locale_switching, :enabled, default: false]
  end

  def page_title
    parts = [t("application.ub_pb"), t("application.app_name")]

    breadcrumb.each do |b|
      parts << b[:label]
    end

    parts.compact.join(" / ")
  end

end
