class HomepageController < ApplicationController

  before_action { add_breadcrumb t("homepage.breadcrumb"), root_path }

  def show
    @news = FeedParser.parse_rss_feed("https://blogs.uni-paderborn.de/ub-katalog?feed=rss")
  end

end
