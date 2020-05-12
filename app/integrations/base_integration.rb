class BaseIntegration
  extend Forwardable

  class << self
    def [](scope, config_filename, environment)
      if environment == "production"
        (@_instances ||= {})[scope.to_s] ||= begin
          create_instance(scope, config_filename, environment)
        end
      else
        create_instance(scope, config_filename, environment)
      end
    rescue Errno::ENOENT
      raise RuntimeError, <<-EOT.strip_heredoc
        Configuration file `#{config_filename}` was not found.
      EOT
    rescue => e
      raise RuntimeError, <<-EOT.strip_heredoc
        There was an error while trying to process the configuration file `#{config_filename}`.
        The original error message was: #{e.message}
      EOT
    end

  private

    def create_instance(scope, config_filename, environment)
      config  = load_config(scope, config_filename, environment)
      adapter = create_adapter(config["adapter"], config["options"])

      # Forward instance level method calls of contract methods to the adapter instance.
      def_instance_delegators :adapter, *self::Contract.instance_methods(false)

      self.new(adapter)
    end

    def load_config(scope, config_filename, environment)
      config = YAML.load(File.read(config_filename))
      raise RuntimeError, "Config is empty" unless config
      raise RuntimeError, "Config for environment '#{environment}' is missing." unless config[environment]

      config = config[environment].with_indifferent_access[scope]
      raise RuntimeError, "Required config for scope '#{scope}' is missing." if config.blank?

      config
    end

    def create_adapter(adapter_class_or_name, options = {})
      case adapter_class_or_name
      when Class
        adapter_class_or_name.new(options)
      when String, Symbol
        adapter_class_or_name = adapter_class_or_name.to_s

        if adapter_class_or_name =~ /[A-Z]/
          adapter_class_or_name.constantize.new(options)
        else
          self::Adapters.const_get("#{adapter_class_or_name.camelcase}Adapter").new(options)
        end
      else
        raise ArgumentError
      end
    end
  end

  def initialize(adapter)
    @adapter = adapter
  end

  attr_reader :adapter
end
