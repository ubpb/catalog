class Account::ApplicationController < ApplicationController

  before_action :authenticate!
  before_action { add_breadcrumb t("account.application.breadcrumb"), account_root_path }
  before_action :check_activation

  layout "account/application"

  private

  def check_activation
    if current_user.needs_activation?
      redirect_to account_activation_path
      false
    end

    true
  end

end
