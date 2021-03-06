module Ils::Adapters
  class AlmaAdapter
    class HoldRequestFactory

      def self.build(data)
        self.new.build(data)
      end

      def build(data)
        Ils::HoldRequest.new(
          id: get_id(data),
          status: get_status(data),
          queue_position: get_queue_position(data),
          requested_at: get_requested_at(data),
          title: get_title(data),
          author: get_author(data),
          description: get_description(data),
          barcode: get_barcode(data)
        )
      end

    private

      def get_id(data)
        data["request_id"]
      end

      def get_status(data)
        case data["request_status"]
        when "NOT_STARTED"   then Ils::Types::HoldRequestStatus[:in_queue]
        when "ON_HOLD_SHELF" then Ils::Types::HoldRequestStatus[:on_hold_shelf]
        when "IN_PROCESS"    then Ils::Types::HoldRequestStatus[:in_process]
        else Ils::Types::HoldRequestStatus[:unknown]
        end
      end

      def get_queue_position(data)
        data["place_in_queue"]
      end

      def get_requested_at(data)
        Time.zone.parse(data["request_time"])
      end

      def get_title(data)
        data["title"]
      end

      def get_author(data)
        data["author"]
      end

      def get_description(data)
        data["description"]
      end

      def get_barcode(data)
        data["barcode"]
      end

    end
  end
end
