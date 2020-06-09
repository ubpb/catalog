module Ils::Adapters
  class AlmaAdapter
    class FeeFactory

      def self.build(alma_fee_hash)
        self.new.build(alma_fee_hash)
      end

      def build(alma_fee_hash)
        Ils::Fee.new(
          id: get_id(alma_fee_hash),
          type: get_type(alma_fee_hash),
          date: get_date(alma_fee_hash),
          balance: get_balance(alma_fee_hash),
          title: get_title(alma_fee_hash),
          barcode: get_barcode(alma_fee_hash)
        )
      end

    private

      def get_id(alma_fee_hash)
        alma_fee_hash["id"]
      end

      def get_type(alma_fee_hash)
        alma_fee_hash.dig("type", "desc")
      end

      def get_date(alma_fee_hash)
        Time.zone.parse(alma_fee_hash["creation_time"])
      end

      def get_balance(alma_fee_hash)
        alma_fee_hash["balance"]
      end

      def get_title(alma_fee_hash)
        alma_fee_hash["title"]
      end

      def get_barcode(alma_fee_hash)
        alma_fee_hash.dig("barcode", "value")
      end

    end
  end
end
