module Ils::Adapters
  class AlmaAdapter
    class GetHoldingsOperation < Operation

      def call(record_id)
        # Get all items for that record id
        get_holdings(record_id).map do |_|
          HoldingFactory.build(_)
        end
      end

    private

      def get_holdings(record_id)
        # Load holdings from Alma for the given record id
        holdings = load_holdings(record_id)

        # Check if there are related records
        related_record_ids = load_related_record_ids(record_id)

        # If there are related records, load their holdings as well
        if related_record_ids.present?
          related_record_ids.each do |rrid|
            holdings += load_holdings(rrid)
          end
        end

        # Filter out holdings with we don't want in discovery
        holdings = holdings.reject do |h|
          # Unassigned holdings
          h.dig("location", "value") =~ /UNASSIGNED/ ||
          # Holdings that are suppressed from publishing
          # For whatever reason this boolean flag is of type string.
          h.dig("suppress_from_publishing") == "true" ||
          # Holdings at location LL (Ausgesondert)
          h.dig("location", "value") == "LL"
        end
      end

      def load_holdings(record_id)
        adapter.api.get(
          "bibs/#{CGI.escape(record_id)}/holdings"
        ).try(:[], "holding") || []
      rescue
        []
      end

      def load_related_record_ids(record_id)
        related_record_ids = []

        # Load the bibs information from Alma
        bibs = adapter.api.get(
          "bibs",
          format: "xml",
          params: {
            mms_id: record_id,
            expand: "p_avail", # Important to get the AVA fields
            view: "full"
          }
        ).xpath("/bibs/bib")

        # Extract record IDs
        record_ids = bibs
          .xpath("//datafield[@tag='AVA']/subfield[@code='0']")
          .map(&:text)

        # Remove the given record id from the list, so that only related record ids
        # are left and make sure the ids are unique.
        related_record_ids = record_ids.reject{|e| e == record_id}.uniq

        related_record_ids
      rescue
        []
      end

    end
  end
end
