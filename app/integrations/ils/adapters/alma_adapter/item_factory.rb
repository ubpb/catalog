module Ils::Adapters
  class AlmaAdapter
    class ItemFactory

      def self.build(alma_item)
        self.new.build(alma_item)
      end

      def build(alma_item)
        item = Ils::Item.new(
          id: get_id(alma_item),
          call_number: get_call_number(alma_item),
          barcode: get_barcode(alma_item),
          status: get_status(alma_item),
          library: get_library(alma_item),
          location: get_location(alma_item)
        )

        #binding.pry

        item
      end

    private

      def get_id(alma_item)
        alma_item.dig("item_data", "pid")
      end

      def get_call_number(alma_item)
        alma_item.dig("item_data", "alternative_call_number").presence ||
        alma_item.dig("holding_data", "call_number").presence
      end

      def get_barcode(alma_item)
        alma_item.dig("item_data", "barcode")
      end

      def get_status(alma_item)
        Ils::ItemStatus.new(
          code: alma_item.dig("item_data", "base_status", "value"),
          label: alma_item.dig("item_data", "base_status", "desc")
        )
      end

      def get_library(alma_item)
        Ils::Library.new(
          code: alma_item.dig("item_data", "library", "value"),
          label: alma_item.dig("item_data", "library", "desc")
        )
      end

      def get_location(alma_item)
        Ils::Location.new(
          code: alma_item.dig("item_data", "location", "value"),
          label: alma_item.dig("item_data", "location", "desc")
        )
      end

    end
  end
end
