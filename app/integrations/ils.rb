class Ils < BaseIntegration

  def self.[](scope, config_filename = "#{Rails.root}/config/ils.yml", environment = Rails.env)
    super(scope, config_filename, environment)
  end

end
