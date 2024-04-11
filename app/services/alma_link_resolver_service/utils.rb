class AlmaLinkResolverService
  module Utils
    #
    # Alma Link Resolver returns a XML response with a context object
    # and a fulltext service object. Both objects contain keys and values.
    #
    # This method cleans/normalizes the key and value for further processing.
    #
    # @return [Array<String, String|Boolean>] Returns a tuple with the cleaned key and value.
    #
    def normalize_key_and_value(key, value)
      # Clean key
      key = key
        &.underscore
        &.downcase
        &.squish
        &.tr(" ", "_")
        .presence

      # Clean value
      value = value
        &.squish
        &.gsub(/[:;,.\/]$/, "") # Clean trailing characters like ":", ",", "." etc.
        &.strip
        .presence

      # Normalize boolean values
      value = case value
      when /\A(0|no|false)\z/i then false
      when /\A(1|yes|true)\z/i then true
      else value; end

      # Return key and value
      [key, value]
    end
  end
end
