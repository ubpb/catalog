module Ils::Adapters
  class AlmaAdapter
    class HoldRequestFactory

      def self.build(data)
        self.new.build(data)
      end

      def build(data)
        Ils::HoldRequest.new(
          id: get_id(data),
          user_id: get_user_id(data),
          status: get_status(data),
          queue_position: get_queue_position(data),
          requested_at: get_requested_at(data),
          expiry_date: get_expiry_date(data),

          is_resource_sharing_request: get_is_resource_sharing_request(data),
          resource_sharing_status: get_resource_sharing_status(data),
          resource_sharing_id: get_resource_sharing_id(data),

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

      def get_user_id(data)
        data["user_primary_id"]
      end

      def get_status(data)
        case data["request_status"]&.upcase&.gsub(" ", "_")
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

      def get_expiry_date(data)
        if date = data["expiry_date"]
          Date.parse(date)
        end
      end

      def get_is_resource_sharing_request(data)
        data["resource_sharing"].present?
      end

      def get_resource_sharing_status(data)
        if status = data.dig("resource_sharing", "status")
          Ils::ResourceSharingStatus.new(
            code: status["value"],
            label: status["desc"]
          )
        end
      end

      def get_resource_sharing_id(data)
        data.dig("resource_sharing", "external_id")
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
