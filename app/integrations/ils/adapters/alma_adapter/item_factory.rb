module Ils::Adapters
  class AlmaAdapter
    class ItemFactory

      def self.build(alma_item)
        self.new.build(alma_item)
      end

      def build(alma_item, hold_requests:nil)
        Ils::Item.new(
          id: get_id(alma_item),
          call_number: get_call_number(alma_item),
          barcode: get_barcode(alma_item),
          is_available: get_is_available(alma_item),
          reshelving_time: get_reshelving_time(alma_item),
          policy: get_policy(alma_item),
          library: get_library(alma_item),
          location: get_location(alma_item),
          process_type: get_process_type(alma_item),
          due_date: get_due_date(alma_item),
          due_date_policy: get_due_date_policy(alma_item),
          is_requested: get_is_requested(alma_item),
          public_note: get_public_note(alma_item),
          expected_arrival_date: get_expected_arrival_date(alma_item),
          description: get_description(alma_item),
          temp_location: get_temp_location(alma_item),
          temp_policy: get_temp_policy(alma_item),
          temp_due_back_date: get_temp_due_back_date(alma_item)
        )
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

      def get_is_available(alma_item)
        alma_item.dig("item_data", "base_status", "value") == "1"
      end

      def get_reshelving_time(alma_item)
        if date_str = alma_item.dig("item_data", "reshelving_time")
          Time.zone.parse(date_str)
        end
      end

      def get_policy(alma_item)
        code  = alma_item.dig("item_data", "policy", "value")
        label = alma_item.dig("item_data", "policy", "desc")

        if code && label
          Ils::ItemPolicy.new(code: code,label: label)
        end
      end

      def get_library(alma_item)
        code  = alma_item.dig("item_data", "library", "value")
        label = alma_item.dig("item_data", "library", "desc")

        if code && label
          Ils::Library.new(code: code,label: label)
        end
      end

      def get_location(alma_item)
        code  = alma_item.dig("item_data", "location", "value")
        label = alma_item.dig("item_data", "location", "desc")

        if code && label
          Ils::Location.new(code: code,label: label)
        end
      end

      def get_process_type(alma_item)
        code  = alma_item.dig("item_data", "process_type", "value")
        label = alma_item.dig("item_data", "process_type", "desc")

        if code && label
          Ils::ProcessType.new(code: code, label: label)
        end
      end

      def get_due_date(alma_item)
        if due_date_str = alma_item.dig("item_data", "due_date")
          Time.zone.parse(due_date_str)
        end
      end

      def get_due_date_policy(alma_item)
        alma_item.dig("item_data", "due_date_policy").presence
      end

      def get_is_requested(alma_item)
        alma_item.dig("item_data", "requested")
      end

      def get_public_note(alma_item)
        alma_item.dig("item_data", "public_note").presence
      end

      def get_expected_arrival_date(alma_item)
        if date_str = alma_item.dig("item_data", "expected_arrival_date")
          Date.parse(date_str)
        end
      end

      def get_description(alma_item)
        alma_item.dig("item_data", "description").presence
      end

      def get_temp_policy(alma_item)
        code  = alma_item.dig("holding_data", "temp_policy", "value")
        label = alma_item.dig("holding_data", "temp_policy", "desc")

        if code && label
          Ils::ItemPolicy.new(code: code,label: label)
        end
      end

      def get_temp_location(alma_item)
        in_temp_location = alma_item.dig("holding_data", "in_temp_location")
        code  = alma_item.dig("holding_data", "temp_location", "value")
        label = alma_item.dig("holding_data", "temp_location", "desc")

        if in_temp_location && code && label
          Ils::Location.new(code: code,label: label)
        end
      end

      def get_temp_due_back_date(alma_item)
        if date_str = alma_item.dig("holding_data", "due_back_date")
          Date.parse(date_str)
        end
      end

    end
  end
end
