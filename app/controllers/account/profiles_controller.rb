class Account::ProfilesController < Account::ApplicationController

  before_action { add_breadcrumb t("account.profiles.breadcrumb"), account_profile_path }

  def show
    ils_user = Ils.get_user(current_user.ils_primary_id)
    User.create_or_update_from_ils_user!(ils_user)
    current_user.reload
  end

end
