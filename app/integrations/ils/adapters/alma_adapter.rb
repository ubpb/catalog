module Ils::Adapters
  class AlmaAdapter < BaseAdapter
    include Ils::Contract

    attr_reader :api

    def initialize(options = {})
      super

      @api = ExlApi.configure do |config|
        config.api_key        = options[:api_key]
        config.api_base_url   = options[:api_base_url] || "https://api-eu.hosted.exlibrisgroup.com/almaws/v1"
        config.language       = options[:language]     || "de"
      end
    end

  end
end
