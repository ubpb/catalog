class JoapController < ApplicationController
  # https://zeitschriftendatenbank.de/fileadmin/user_upload/ZDB/pdf/services/JOP_Dokumentation_XML-Dienst.pdf

  # https://services.dnb.de/fize-service/gvr/full.xml?genre=journal&issn=2194-4210&pid=bibid%3DUBPB

  BASE_URL = "https://services.dnb.de/fize-service/gvr/full.xml"

  class PrintResult
    attr_reader :title, :call_number, :period, :comment

    def initialize(title:, call_number:, period:, comment:)
      @title = title
      @call_number = call_number
      @period = period
      @comment = comment
    end
  end

  def show
    if (result = resolve_issn(params[:issn]))
      # We have found a result, lets parse it...

      # For print results only select results with state = "2"
      @print_results = result.xpath("//PrintData/ResultList/Result[@state='2']").map do |node|
        PrintResult.new(
          title: node.at_xpath("Title")&.text || "n.n.",
          call_number: node.at_xpath("Signature")&.text,
          period: node.at_xpath("Period")&.text,
          comment: node.at_xpath("Holding_comment")&.text
        )
      end

      # Electronic results
      # Maybe later...
    end
  end

  private

  def resolve_issn(issn)
    response = http_client.get(
      BASE_URL,
      {
        pid: "bibid=UBPB",
        sid: "bib:ubpb",
        genre: "journal",
        issn: issn
      }
    )

    if response.status == 200 && response.headers[:content_type] =~ /text\/xml/
      Nokogiri::XML.parse(response.body).remove_namespaces!
    end
  rescue Faraday::Error
    nil
  end

  def http_client
    Faraday.new(
      headers: {
        accept: "text/xml",
        "content-type": "text/xml"
      }
    ) do |faraday|
      faraday.response :raise_error
    end
  end

end
