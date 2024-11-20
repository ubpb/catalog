class ViewablePasswordInput < SimpleForm::Inputs::PasswordInput

  def input(wrapper_options)
    input_id = @builder.field_id(attribute_name)
    toggle_button_id = @builder.field_id(attribute_name, :toogle_button)
    error_class = has_errors? ? (wrapper_options[:error_class].presence || "is-invalid") : ""
    merged_input_options = merge_wrapper_options(input_html_options, wrapper_options)

    template.content_tag :div, class: error_class do
      template.concat render_input_group(merged_input_options, toggle_button_id)
      template.concat render_javascript(input_id, toggle_button_id)
    end
  end

  private

  def render_input_group(input_options, toggle_button_id)
    current_value = @builder.object.send(attribute_name)

    template.content_tag :div, class: "input-group" do
      template.concat @builder.password_field(attribute_name, input_options.merge({
        value: current_value,
        spellcheck: false,
        autocomplete: "off"
      }))
      template.concat render_show_password_button(toggle_button_id)
    end
  end

  def render_show_password_button(toggle_button_id)
    template.content_tag(:span, class: "input-group-text", id: toggle_button_id, style: "cursor: pointer") do
      template.concat eye_open_icon
    end
  end

  def render_javascript(input_id, toggle_button_id)
    template.javascript_tag <<~JAVASCRIPT
      (function() {
        var input = document.getElementById("#{input_id}");
        var toogleButton = document.getElementById("#{toggle_button_id}");

        if (input && toogleButton) {
          toogleButton.addEventListener("click", function(e) {
            e.preventDefault();

            if (input.type === "password") {
              input.type = "text";
              toogleButton.innerHTML = `#{eye_close_icon}`;
              input.focus();
            } else {
              input.type = "password";
              toogleButton.innerHTML = `#{eye_open_icon}`;
              input.focus();
            }
          });
        };
      })();
    JAVASCRIPT
  end

  def eye_open_icon
    '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-eye" viewBox="0 0 16 16">
      <path d="M16 8s-3-5.5-8-5.5S0 8 0 8s3 5.5 8 5.5S16 8 16 8M1.173 8a13 13 0 0 1 1.66-2.043C4.12 4.668 5.88 3.5 8 3.5s3.879 1.168 5.168 2.457A13 13 0 0 1 14.828 8q-.086.13-.195.288c-.335.48-.83 1.12-1.465 1.755C11.879 11.332 10.119 12.5 8 12.5s-3.879-1.168-5.168-2.457A13 13 0 0 1 1.172 8z"/>
      <path d="M8 5.5a2.5 2.5 0 1 0 0 5 2.5 2.5 0 0 0 0-5M4.5 8a3.5 3.5 0 1 1 7 0 3.5 3.5 0 0 1-7 0"/>
    </svg>'.html_safe # rubocop:disable Rails/OutputSafety
  end

  def eye_close_icon
    '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-eye-slash" viewBox="0 0 16 16">
      <path d="M13.359 11.238C15.06 9.72 16 8 16 8s-3-5.5-8-5.5a7 7 0 0 0-2.79.588l.77.771A6 6 0 0 1 8 3.5c2.12 0 3.879 1.168 5.168 2.457A13 13 0 0 1 14.828 8q-.086.13-.195.288c-.335.48-.83 1.12-1.465 1.755q-.247.248-.517.486z"/>
      <path d="M11.297 9.176a3.5 3.5 0 0 0-4.474-4.474l.823.823a2.5 2.5 0 0 1 2.829 2.829zm-2.943 1.299.822.822a3.5 3.5 0 0 1-4.474-4.474l.823.823a2.5 2.5 0 0 0 2.829 2.829"/>
      <path d="M3.35 5.47q-.27.24-.518.487A13 13 0 0 0 1.172 8l.195.288c.335.48.83 1.12 1.465 1.755C4.121 11.332 5.881 12.5 8 12.5c.716 0 1.39-.133 2.02-.36l.77.772A7 7 0 0 1 8 13.5C3 13.5 0 8 0 8s.939-1.721 2.641-3.238l.708.709zm10.296 8.884-12-12 .708-.708 12 12z"/>
    </svg>'.html_safe # rubocop:disable Rails/OutputSafety
  end

end
