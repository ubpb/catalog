class FulltextService::ResultFilter
  BLACKLIST = [
    /ebrary.com/,
    /contentreserve.com/,
    /digitale-objekte.hbz-nrw.de/
  ]

  PRIORITY_LIST = [
    /bibid=UBPB/,
    /bib_id=ub_pb/,
    /digital\.ub\.uni-paderborn\.de/,
    /digital\.ub\.upb\.de/,
    /uni-paderborn\.de/,
    /upb\.de/,
    /uni-regensburg\.de/,
    /ebscohost/,
    /jstor/,
    /nbn-resolving\.de/
  ]

  class << self
    delegate :filter, to: :new
  end

  def filter(results)
    # Apply blacklist
    results = results.reject do |result|
      BLACKLIST.any? { |i| i.match(result.url) }
    end

    # Sort remaining results by priority
    results.sort do |a, b|
      ia = PRIORITY_LIST.find_index { |regexp| regexp.match(a.url) } || 1000
      ib = PRIORITY_LIST.find_index { |regexp| regexp.match(b.url) } || 1000
      ia <=> ib
    end
  end

end
