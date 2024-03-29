module Ils::Adapters
  class AlmaAdapter < Ils::Adapter
    include Ils::Contract

    attr_reader :api

    def initialize(options = {})
      super

      @api = AlmaApi::Client.configure do |config|
        config.api_key  = options[:api_key]
        config.base_url = options[:api_base_url] || "https://api-eu.hosted.exlibrisgroup.com/almaws/v1"
        config.language = options[:language]     || "de"
      end
    end

    def current_loans_sortable_fields
      ["due_date", "loan_date", "barcode", "title"]
    end

    def current_loans_sortable_default_field
      "due_date"
    end

    def current_loans_sortable_default_direction
      "asc"
    end

    def former_loans_sortable_fields
      ["return_date", "loan_date", "barcode", "title"]
    end

    def former_loans_sortable_default_field
      "return_date"
    end

    def former_loans_sortable_default_direction
      "desc"
    end

  end
end
