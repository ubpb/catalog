class Account::ApplicationController < ApplicationController

  before_action :authenticate!
  before_action { add_breadcrumb t("account.application.breadcrumb"), account_root_path }

  layout "account/application"

end
