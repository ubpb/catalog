class FulltextService::Result

  attr_reader :source, :url, :label, :coverage, :note, :options

  def initialize(source:, url:, label: nil, coverage: nil, note: nil, options: {})
    @source = source
    @url = url
    @label = label
    @coverage = coverage
    @note = note
    @options = options
  end

end
