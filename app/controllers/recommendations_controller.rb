class RecommendationsController < RecordsController

  ENABLED           = Config[:recommendations, :enabled, default: false]
  BASE_URL          = Config[:recommendations, :bx_base_url, default: "http://recommender.service.exlibrisgroup.com/service/recommender/openurl"]
  ACCESS_TOKEN      = Config[:recommendations, :bx_access_token, default: nil]
  READ_TIMEOUT      = Config[:recommendations, :read_timeout, default: 2.0]
  RESOLVER_BASE_URL = Config[:recommendations, :resolver_base_url, default: "https://katalog.ub.uni-paderborn.de/openurl"]
  SOURCE            = Config[:recommendations, :source, default: "global"]
  MAX_RECORDS       = Config[:recommendations, :max_records, default: 15]
  THRESHOLD         = Config[:recommendations, :threshold, default: 50]

  def index
    @recommendations = get_recommendations
  end

private

  def get_recommendations
    openurl_params = @record.resolver_link&.url&.split("?")&.last
    return [] unless ENABLED || ACCESS_TOKEN.blank? || openurl_params.blank?

    if bx_response = load_recommendations_from_bx(openurl_params)
      parse_bx_response(bx_response)
    else
      []
    end
  end

  def load_recommendations_from_bx(openurl_params)
    return nil unless ENABLED || ACCESS_TOKEN.blank?

    uri = URI.parse("#{BASE_URL}?token=#{ACCESS_TOKEN}&format=xml&source=#{SOURCE}&maxRecords=#{MAX_RECORDS}&threshold=#{THRESHOLD}&#{openurl_params}")
    response = Net::HTTP.start(uri.host, uri.port) do |http|
      http.read_timeout = READ_TIMEOUT
      request = Net::HTTP::Get.new(uri)
      http.request(request)
    end

    response if response.is_a?(Net::HTTPSuccess)
  rescue Net::ReadTimeout
    nil
  end

  def parse_bx_response(response)
    recommendations = []

    xml = Nokogiri::XML(response.body).remove_namespaces!
    xml.xpath("//context-object").each.with_index do |context_node, i|
      next if i == 0 # The first recommendation is always the requested record

      node = context_node.at_xpath("referent/*/metadata").first_element_child
      case node.name
      when "journal" then
        recommendations << {
          type: :journal,
          link: build_open_url_link(context_node, type: :journal),
          authors: node.xpath("authors/author").map { |author_node|
            first = author_node.at_xpath("aufirst")&.text&.presence
            last = author_node.at_xpath("aulast")&.text&.presence
            [last, first].compact.join(", ")
          },
          atitle: node.at_xpath("atitle")&.text&.presence,
          jtitle: node.at_xpath("jtitle")&.text&.presence,
          date: node.at_xpath("date")&.text&.slice(0..3)&.presence,
          volume: node.at_xpath("volume")&.text&.presence,
          pages: node.at_xpath("pages")&.text&.presence,
          issue: node.at_xpath("issue")&.text&.presence,
          issn: node.at_xpath("issn")&.text&.presence,
          eissn: node.at_xpath("eissn")&.text&.presence,
        }
      when "book" then
        recommendations << {
          type: :book,
          link: build_open_url_link(context_node, type: :book),
          authors: node.xpath("authors/author").map { |author_node|
            first = author_node.at_xpath("aufirst")&.text&.presence
            last = author_node.at_xpath("aulast")&.text&.presence
            [last, first].compact.join(", ")
          },
          title: node.at_xpath("title")&.text&.presence || node.at_xpath("btitle")&.text&.presence || "n.n.",
          isbn: node.at_xpath("isbn")&.text&.presence,
          date: node.at_xpath("date")&.text&.slice(0..3)&.presence,
          publisher: node.at_xpath("pub")&.text&.presence,
        }
      end
    end

    recommendations
  rescue
    []
  end

  def build_open_url_link(context_node, type:)
    metadata_node = context_node.at_xpath("referent/*/metadata").first_element_child
    identifiers   = context_node.xpath("referent/identifier").map{|i| i.text&.presence}.compact

    fields = {}
    fields["ctx_ver"]     = context_node.attr("version")
    fields["rft_val_fmt"] = type == :book ? "info:ofi/fmt:kev:mtx:book" : "info:ofi/fmt:kev:mtx:article"
    fields["rft.atitle"]  = metadata_node.at_xpath("atitle")&.text&.presence
    fields["rft.auinit"]  = metadata_node.at_xpath("authors/author/auinit")&.text&.presence
    fields["rft.auinit1"] = metadata_node.at_xpath("authors/author/auinit1")&.text&.presence
    fields["rft.auinitm"] = metadata_node.at_xpath("authors/author/auinitm")&.text&.presence
    fields["rft.aulast"]  = metadata_node.at_xpath("authors/author/aulast")&.text&.presence
    fields["rft.au"]      = metadata_node.at_xpath("authors/au")&.text&.presence
    fields["rft.doi"]     = metadata_node.at_xpath("doi")&.text&.presence
    fields["rft.eissn"]   = metadata_node.at_xpath("eissn")&.text&.presence
    fields["rft.epage"]   = metadata_node.at_xpath("epage")&.text&.presence
    fields["rft.genre"]   = metadata_node.at_xpath("genre")&.text&.presence
    fields["rft.issn"]    = metadata_node.at_xpath("issn")&.text&.presence
    fields["rft.issue"]   = metadata_node.at_xpath("issue")&.text&.presence
    fields["rft.jtitle"]  = metadata_node.at_xpath("jtitle")&.text&.presence
    fields["rft.pages"]   = metadata_node.at_xpath("pages")&.text&.presence
    fields["rft.pub"]     = metadata_node.at_xpath("pub")&.text&.presence
    fields["rft.date"]    = metadata_node.at_xpath("date")&.text&.presence
    fields["rft.spage"]   = metadata_node.at_xpath("spage")&.text&.presence
    fields["rft.title"]   = metadata_node.at_xpath("title")&.text&.presence
    fields["rft.volume"]  = metadata_node.at_xpath("volume")&.text&.presence
    fields["rfr_id"]      = context_node.at_xpath("referrer/identifier")&.text&.presence
    fields["rft_dat"]     = context_node.at_xpath("referent/private-data/rfr_dat")&.text&.presence
    #fields["rft.object_id"] = identifiers.find{|i| i.match("sfxid")}

    params = fields.map do |k,v|
      "#{k}=#{v}"
    end

    "#{RESOLVER_BASE_URL}?#{params.join("&")}"
  end

end
