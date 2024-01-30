class Account::TodosController < Account::ApplicationController

  # Do not enforce todos for the controller that lists todos,
  # as this would create an infinite redirect loop.
  skip_before_action :enforce_todos!

  before_action { add_breadcrumb t("account.todos.breadcrumb"), account_todos_path }

  layout "application"

  def index
    @blocking_todos = current_user.blocking_todos
    @optional_todos = current_user.optional_todos
  end

end
