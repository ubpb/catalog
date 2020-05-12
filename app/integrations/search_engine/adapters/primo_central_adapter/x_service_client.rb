module SearchEngine::Adapters
  class PrimoCentralAdapter
    class XServiceClient

      def initialize(base_url, institution)
        @base_url = base_url
        @institution = institution
      end

      def get_record(record_id, on_campus: false)
        Faraday.get("#{@base_url}/search/brief", {
          query: "rid,exact,#{record_id}",
          institution: @institution,
          loc: "adaptor,primo_central_multiple_fe",
          onCampus: on_campus,
          indx: 1,
          bulkSize: 1,
          pcAvailability: true
        }).body
      end

      def search(params, on_campus: false, from: 1, size: 10)
        _params = params.merge(
          institution: @institution,
          loc: "adaptor,primo_central_multiple_fe",
          onCampus: on_campus,
          indx: from,
          bulkSize: size,
          pcAvailability: true
        )

        conn = Faraday.new(url: @base_url, request: { :params_encoder => Faraday::FlatParamsEncoder }) do |conn|
          # Log requests
          conn.response :logger
          # Adapter must be last
          conn.adapter Faraday.default_adapter
        end

        conn.get("search/brief", _params).body
      end

    end
  end
end
