class SearchEngine < BaseIntegration

  class Error < IntegrationError ; end

  class QuerySyntaxError < Error ; end

  def self.[](scope, config_filename = "#{Rails.root}/config/search_engine.yml", environment = Rails.env)
    super(scope, config_filename, environment)
  end

end
