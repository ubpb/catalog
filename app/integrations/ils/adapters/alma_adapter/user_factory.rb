module Ils::Adapters
  class AlmaAdapter
    class UserFactory

      def self.build(alma_user_hash)
        new.build(alma_user_hash)
      end

      def build(alma_user_hash)
        Ils::User.new(
          id: get_id(alma_user_hash),
          user_group: get_user_group(alma_user_hash),
          first_name: get_firstname(alma_user_hash),
          last_name: get_lastname(alma_user_hash),
          email: get_email(alma_user_hash),
          notes: get_nodes(alma_user_hash),
          force_password_change: get_force_password_change(alma_user_hash),
          barcode: get_barcode(alma_user_hash),
          pin: get_pin(alma_user_hash),
          expiry_date: get_expiry_date(alma_user_hash),
          blocks: get_blocks(alma_user_hash)
        )
      end

      private

      def get_id(alma_user_hash)
        alma_user_hash["primary_id"]
      end

      def get_user_group(alma_user_hash)
        code  = alma_user_hash.dig("user_group", "value").presence
        label = alma_user_hash.dig("user_group", "desc").presence

        if code && label
          Ils::UserGroup.new(code: code, label: label)
        end
      end

      def get_firstname(alma_user_hash)
        alma_user_hash["first_name"]
      end

      def get_lastname(alma_user_hash)
        alma_user_hash["last_name"]
      end

      def get_email(alma_user_hash)
        emails = alma_user_hash["contact_info"]["email"]
        emails.find { |email| email["preferred"] == true }.try(:[], "email_address")
      end

      def get_nodes(alma_user_hash)
        alma_user_hash["user_note"].find_all do |note|
          note["user_viewable"] == true
        end.map do |note|
          note["note_text"]
        end
      end

      def get_force_password_change(alma_user_hash)
        alma_user_hash["force_password_change"].presence&.casecmp?("true") ? true : false
      end

      def get_barcode(alma_user_hash)
        alma_user_hash["user_identifier"].find do |id|
          id.dig("id_type", "value") == "05"
        end&.dig("value")&.upcase
      end

      def get_pin(alma_user_hash)
        alma_user_hash["pin_number"].presence
      end

      def get_expiry_date(alma_user_hash)
        expiry_date = alma_user_hash["expiry_date"].presence
        Date.parse(expiry_date) if expiry_date
      end

      def get_blocks(alma_user_hash)
        alma_user_hash["user_block"].map do |block|
          next if block["block_status"] != "ACTIVE"

          Ils::UserBlock.new(
            code: block["block_description"]["value"].presence,
            label: block["block_description"]["desc"].presence,
            created_at: Time.zone.parse(block["created_date"])
          )
        end.compact
      end

    end
  end
end
