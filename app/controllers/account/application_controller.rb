class Account::ApplicationController < ApplicationController

  before_action :authenticate!
  before_action { add_breadcrumb "Mein Bibliothekskonto", account_root_path }

  layout "account/application"

end
