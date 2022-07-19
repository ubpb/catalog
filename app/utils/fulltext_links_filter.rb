class FulltextLinksFilter
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

  def self.filter(links)
    if links.present? && links.is_a?(Array)
      flinks = links.dup
      #flinks = apply_blacklist(flinks)
      flinks = sort_by_priority(flinks)
    else
      links
    end
  end

protected

  def self.apply_blacklist(links)
    links.reject do |link|
      BLACKLIST.any?{|i| i.match(link.url)}
    end
  end

  def self.sort_by_priority(links)
    links.sort do |a, b|
      ia = PRIORITY_LIST.find_index{|regexp| regexp.match(a.url)} || 1000
      ib = PRIORITY_LIST.find_index{|regexp| regexp.match(b.url)} || 1000
      ia <=> ib
    end
  end

end
