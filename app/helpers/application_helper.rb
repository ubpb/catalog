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

  def optional_block(optional_value, &block)
    return unless block_given?

    if (present_value = optional_value).present?
      capture(present_value, &block)
    end
  end

  def optional_value(optional_value, blank_value: "–", &block)
    if (present_value = optional_value).present?
      if block_given?
        capture(present_value, &block)
      else
        present_value
      end
    else
      blank_value if blank_value.present?
    end
  end

end
