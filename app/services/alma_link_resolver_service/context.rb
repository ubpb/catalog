class AlmaLinkResolverService
  #
  # Utility class to store and access the context object
  # returned from Alma as part of the Open URL resolving.
  #
  # Alma uses the ANSI/NISO Z39.88-2004 standard for OpenURLs as
  # described here:
  #
  # https://groups.niso.org/higherlogic/ws/public/download/14833/z39_88_2004_r2010.pdf
  #
  # However, we use the context object only for displaying the metadata in the UI.
  # We don't use it for further processing of the OpenURL.
  #
  # Some keys may occur multiple times in the context object (incomming values get merged
  # with resolved values from Alma), so our internal representation is a hash with arrays
  # as values.
  #
  # We assume that the last value of that array is the most relevant one in cases
  # where we expect a single value.
  #
  class Context

    class << self
      include Utils

      #
      # Extracts the context object from the Alma Link Resolver result.
      # We normalize the keys and values to be more consistent. We also remove
      # keys with nil values.
      #
      def parse(alma_result)
        context_hash = alma_result.xpath("//context_object/keys/key").each_with_object({}) do |key_node, memo|
          key, value = normalize_key_and_value(key_node.attr("id"), key_node.text)

          if key && !value.nil? # value is either nil, a string or a boolean
            memo[key] ||= []
            memo[key] << value
          end

          memo
        end

        Context.new(context_hash)
      end
    end

    def initialize(context_hash)
      @context_hash = context_hash
    end

    def to_h
      @context_hash
    end

    def to_s
      @context_hash.to_s
    end

    def [](id)
      @context_hash[id]
    end

    def values(id)
      self[id]&.map(&:presence)&.compact
    end

    def value(id)
      values(id)&.last&.presence
    end

    def mms_id
      value("rft.mms_id")
    end

    def is_book?
      value("rft.btitle").present?
    end

    def is_journal?
      value("rft.jtitle").present?
    end

    def fulltext_available?
      value("full_text_indicator") == true
    end

    def article_title
      value("rft.atitle")
    end

    def journal_or_book_title
      value("rft.jtitle") || value("rft.btitle") || value("rft.title")
    end

    def authors
      self["rft.au"]&.join("; ")
    end

    def publisher
      value("rft.pub")
    end

    def place_of_publication
      value("rft.place")
    end

    def year_of_publication
      value("rft.year")
    end

    def edition
      value("rft.edition")
    end

    def volume
      value("rft.volume")
    end

    def issue
      value("rft.issue")
    end

    def pages
      value("rft.pages")
    end

    def issn
      values("rft.issn")&.join(", ")
    end

    def eissn
      values("rft.eissn")&.join(", ")
    end

    def isbn
      values("rft.isbn")&.join(", ")
    end

    def eisbn
      values("rft.eisbn")&.join(", ")
    end

    def identifiers
      ids = []
      ids << "ISSN: #{issn}" if issn
      ids << "eISSN: #{eissn}" if eissn
      ids << "ISBN: #{isbn}" if isbn
      ids << "eISBN: #{eisbn}" if eisbn
      ids
    end
  end
end
