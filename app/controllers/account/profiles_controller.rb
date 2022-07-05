class Account::ProfilesController < Account::ApplicationController

  before_action { add_breadcrumb t("account.profiles.breadcrumb"), account_profile_path }

  def show
  end

end
