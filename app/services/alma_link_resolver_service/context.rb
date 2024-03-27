class AlmaLinkResolverService
  # Utility class to store and access the context object
  # returned from Alma as part of the Open URL resolving.
  #
  # If Alma founds a matching record it adds additional keys to the
  # context object. The context object still contains the keys as they
  # were passed to Alma as part of the Open URL params. This may result
  # in multiple keys with different values (the original from the URL and the enhanced
  # from Alma). We assume that the last one of such multiple occurrences is the enhanced
  # one from Alma.
  #
  # We also assume that the value of the context hash is always an array to account for
  # multiple values for a given key.
  class Context
    def initialize(context_hash)
      @context_hash = context_hash
    end

    # # Accessor for values
    def values(id)
      @context_hash[id]
    end

    def value(id)
      values(id)&.last
    end

    def value_first(id)
      values(id)&.first
    end
    # # Convenient methods for fields we use in the UI
    # def alma_id; value("rft.mms_id"); end

    def title
      if is_journal?
        return value("rft.jtitle") || value("rft.title")
      end

      value_first("rft.btitle").presence || value("rft.title")
    end

    def authors
      values("rft.au")&.join("; ")
    end

    def publisher
      value("rft.pub")
    end

    def place_of_publication
      value("rft.place")
    end

    def date_of_publication
      value("rft.pubdate")
    end

    private

    def is_book?
      value("rft.btitle").present?
    end

    def is_journal?
      value("rft.jtitle").present?
    end
  end
end
