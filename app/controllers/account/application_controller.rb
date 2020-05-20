class Account::ApplicationController < ApplicationController

  before_action :authenticate!

  layout "account/application"

end
