# Where the I18n library should search for translation files
I18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]

I18n.available_locales = [:de]
I18n.default_locale = :de

# Make sure i18n uses default locale as fallback
Rails.application.config.i18n.fallbacks = true
