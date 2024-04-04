class FulltextService::Result

  attr_reader :source, :url, :label, :coverage, :note

  def initialize(source:, url:, label: nil, coverage: nil, note: nil)
    @source = source
    @url = url
    @label = label
    @coverage = coverage
    @note = note
  end

end
