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
  # Some keys may occur multiple times in the context object, so our internal
  # representation is a hash with arrays as values.
  #
  # We assume that the first value of that array is the most relevant one in cases
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

    def first_value(id)
      self[id]&.first
    end

    def mms_id
      first_value("rft.mms_id")
    end

    def fulltext_available?
      first_value("full_text_indicator") == true
    end

    def journal_or_series_title
      first_value("rft.jtitle") || first_value("rft.stitle")
    end

    def title
      first_value("rft.atitle") || first_value("rft.btitle") || first_value("rft.title")
    end

    def authors
      self["rft.au"]&.join("; ")
    end

    def publisher
      first_value("rft.pub")
    end

    def place_of_publication
      first_value("rft.place")
    end

    def year_of_publication
      first_value("rft.year")
    end

    def volume
      first_value("rft.volume")
    end

    def pages
      first_value("rft.pages")
    end
  end
end
