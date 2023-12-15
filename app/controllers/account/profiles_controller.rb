class Account::ProfilesController < Account::ApplicationController

  before_action { add_breadcrumb t("account.profiles.breadcrumb"), account_profile_path }
  before_action :load_ils_user, only: [:show]

  def show
    render :show
  end

  private

  def load_ils_user
    @ils_user = current_user.ils_user(force_reload: true)
  end

end
