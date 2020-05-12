module Ils::Adapters
  class AlmaAdapter
    class LoanFactory

      def self.build(alma_item_loan)
        self.new.build(alma_item_loan)
      end

      def build(alma_item_loan)
        Ils::Loan.new(
          id: get_id(alma_item_loan),
          loan_date: get_loan_date(alma_item_loan),
          due_date: get_due_date(alma_item_loan),
          renewable: get_renewable(alma_item_loan),
          item_id: get_item_id(alma_item_loan),
          record_id: get_record_id(alma_item_loan),
          barcode: get_barcode(alma_item_loan),
          call_number: get_call_number(alma_item_loan),
          fine: get_fine(alma_item_loan),
          title: get_title(alma_item_loan),
          author: get_author(alma_item_loan),
          description: get_description(alma_item_loan)
        )
      end

    private

      def get_id(alma_item_loan)
        alma_item_loan["loan_id"]
      end

      def get_loan_date(alma_item_loan)
        Date.parse(alma_item_loan["loan_date"])
      end

      def get_due_date(alma_item_loan)
        Date.parse(alma_item_loan["due_date"])
      end

      def get_renewable(alma_item_loan)
        alma_item_loan["renewable"]
      end

      def get_item_id(alma_item_loan)
        alma_item_loan["item_id"]
      end

      def get_record_id(alma_item_loan)
        alma_item_loan["mms_id"]
      end

      def get_barcode(alma_item_loan)
        alma_item_loan["item_barcode"]
      end

      def get_call_number(alma_item_loan)
        alma_item_loan["call_number"]
      end

      def get_fine(alma_item_loan)
        alma_item_loan["loan_fine"]
      end

      def get_title(alma_item_loan)
        alma_item_loan["title"]
      end

      def get_author(alma_item_loan)
        alma_item_loan["author"]
      end

      def get_description(alma_item_loan)
        alma_item_loan["description"]
      end

    end
  end
end
