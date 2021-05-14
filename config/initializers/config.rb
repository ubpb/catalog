class Config
  class << self

    def configure(config)
      @config = config
    end

    def [](*params, default: nil)
      @config&.dig(*params) || default
    end

  end
end

config = Rails.application.config_for(:application)
Config.configure(config)
