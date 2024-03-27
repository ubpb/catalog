class AlmaLinkResolverService
  class FulltextService
    def initialize(resolution_url:, keys:)
      @resolution_url = resolution_url
      @keys = keys
    end

    def fulltext_url = @resolution_url

    def package_name = @keys["package_display_name"]

    def is_free? = @keys["is_free"]

    def public_note = @keys["public_note"]

    # FIXME: This is a quick hack to get the availability string in german for the UI
    # We need to integrate this into i18n in a proper way.
    def availability
      @keys["availability"]
        &.gsub("<br>", "; ")
        &.gsub("Available", "Verfügbar")
        &.gsub("from", "von")
        &.gsub("volume:", "Band:")
        &.gsub("issue:", "Heft:")
        &.gsub("until", "bis")
        &.gsub("Most recent", "Neuste")
        &.gsub("year(s)", "Jahr(e)")
        &.gsub("not available", "nicht verfügbar")
        &.gsub("available", "verfügbar")
        &.gsub("months", "Monate")
    end
  end
end
