class SearchEngine < BaseIntegration

  def self.[](scope, config_filename = "#{Rails.root}/config/search_engine.yml", environment = Rails.env)
    super(scope, config_filename, environment)
  end

end
