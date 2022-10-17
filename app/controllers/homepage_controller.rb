class HomepageController < ApplicationController

  before_action { add_breadcrumb t("homepage.breadcrumb"), root_path }

  def show
    if params[:q].present?
      sr = SearchEngine::SearchRequest.parse("sr[q,any]=#{Addressable::URI.encode_component(params[:q], Addressable::URI::CharacterClasses::UNRESERVED)}")

      return redirect_to(
        new_search_request_path(sr)
      )
    end

    @news = FeedParser.parse_rss_feed("https://blogs.uni-paderborn.de/ub-katalog?feed=rss")
  end

end
