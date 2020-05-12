module SearchEngine::Adapters
  class ElasticSearchAdapter
    class ResourceLinksFilter
      BLACKLIST = [
        /ebrary.com/,
        /contentreserve.com/
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

      attr_reader :links

      def initialize(links)
        @links = links
      end

      def filter
        links = apply_blacklist(@links)
        links = sort_by_priority(links)
      end

    private

      def apply_blacklist(links)
        links.reject do |link|
          BLACKLIST.any?{|i| i.match(link.url)}
        end
      end

      def sort_by_priority(links)
        links.sort do |a, b|
          ia = PRIORITY_LIST.find_index{|regexp| regexp.match(a.url)} || 1000
          ib = PRIORITY_LIST.find_index{|regexp| regexp.match(b.url)} || 1000
          ia <=> ib
        end
      end

    end
  end
end
