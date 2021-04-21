class Ils < BaseIntegration

  def self.[](scope, config_filename = "#{Rails.root}/config/ils.yml", environment = Rails.env)
    super(scope, config_filename, environment)
  end

  def self.method_missing(method, *args)
    if self[:default]
      self[:default].send(method, *args)
    else
      super
    end
  end

end
