class Admin::ApplicationController < ApplicationController
  before_action :authenticate!

  before_action -> {
    add_breadcrumb("Admin", admin_root_path)
  }
end
