class FulltextService::Result

  attr_reader :source, :url, :label, :coverage, :note, :retraction_notice_url, :options

  def initialize(source:, url:, label: nil, coverage: nil, note: nil, retraction_notice_url: nil, options: {})
    @source = source
    @url = url
    @label = label
    @coverage = coverage
    @note = note
    @retraction_notice_url = retraction_notice_url
    @options = options
  end

end
