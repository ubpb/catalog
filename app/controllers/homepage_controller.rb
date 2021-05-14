class HomepageController < ApplicationController

  before_action { add_breadcrumb t("homepage.breadcrumb"), root_path }

end
