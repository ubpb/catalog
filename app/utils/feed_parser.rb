class FeedParser

  def self.parse_rss_feed(url)
    cache_key = "feed_url_#{url}"
    Rails.cache.fetch(cache_key, expires_in: 60.minutes) do
      Timeout.timeout(5) do
        URI.open(url) do |rss| # rubocop:disable Security/Open
          if (feed = RSS::Parser.parse(rss)).present?
            feed.channel.items.slice(0..4).map do |item, i|
              {
                title: item.title,
                description: item.description,
                categories: item.categories.map { |category| category.content },
                date: item.date,
                link: item.link
              }
            end
          end
        end
      end
    rescue StandardError
      nil
    end
  end

end
