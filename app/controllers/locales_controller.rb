class LocalesController < ApplicationController

  def switch
    locale = params[:locale]&.to_s&.strip&.to_sym

    locale = if I18n.available_locales.include?(locale)
      locale
    else
      I18n.default_locale
    end

    cookies[:_catalog_locale] = {value: locale, expires: 1.year.from_now}

    redirect_back fallback_location: root_path
  end

end
