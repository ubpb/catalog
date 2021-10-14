module Ils::Adapters
  class AlmaAdapter
    class GetAvailabilitiesOperation < Operation

      def call(record_ids)
        availabilities = get_bibs(clean_record_ids(record_ids)).map do |bib|
          record_id     = bib.at_xpath("mms_id")&.text
          record_format = bib.at_xpath("record_format")&.text
          record_xml    = bib.at_xpath("record")

          if record_id && record_format
            {
              record_id: record_id,
              availabilities: get_availabilities(record_xml, record_format: record_format)
            }
          end
        end.compact

        # TODO: We return a hash for now, because this is subject to change.
        return availabilities
      end

    private

      def clean_record_ids(record_ids)
        (record_ids || [])
          .map(&:strip)
          .map(&:presence)
          .uniq
          .compact
      end

      def get_bibs(record_ids)
        adapter.api.get(
          "bibs",
          format: "application/xml",
          params: {
            mms_id: record_ids.join(","),
            expand: "p_avail,e_avail,requests",
            view: "full"
          }
        ).xpath("/bibs/bib")
      rescue ExlApi::LogicalError => e
        # TODO: Log error
        []
      end

      def get_availabilities(record_xml, record_format:)
        return [] if record_format != "marc21"

        Metacrunch::Marcxml
          .parse(record_xml.to_xml)
          .datafields("AVA").map do |datafield|
            {
              availability: datafield.subfields("e")&.first&.value,
              total_items: datafield.subfields("f")&.first&.value,
              non_available_items: datafield.subfields("g")&.first&.value,
              library: datafield.subfields("q")&.first&.value,
              location: datafield.subfields("c")&.first&.value
            }
          end
          .compact
      end

    end
  end
end
