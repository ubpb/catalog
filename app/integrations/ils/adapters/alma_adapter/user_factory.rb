module Ils::Adapters
  class AlmaAdapter
    class UserFactory

      def self.build(alma_user_hash)
        self.new.build(alma_user_hash)
      end

      def build(alma_user_hash)
        Ils::User.new(
          id: get_id(alma_user_hash),
          firstname: get_firstname(alma_user_hash),
          lastname: get_lastname(alma_user_hash),
          email: get_email(alma_user_hash),
          notes: get_nodes(alma_user_hash)
        )
      end

    private

      def get_id(alma_user_hash)
        alma_user_hash["primary_id"]
      end

      def get_firstname(alma_user_hash)
        alma_user_hash["first_name"]
      end

      def get_lastname(alma_user_hash)
        alma_user_hash["last_name"]
      end

      def get_email(alma_user_hash)
        emails = alma_user_hash["contact_info"]["email"]

        emails.find(->{{}}){|email| email["preferred"] == true}["email_address"] ||
          emails.first["email_address"]
      end

      def get_nodes(alma_user_hash)
        alma_user_hash["user_note"].find_all{|note| note["user_viewable"] == true}.map{|note| note["note_text"]}
      end

    end
  end
end
