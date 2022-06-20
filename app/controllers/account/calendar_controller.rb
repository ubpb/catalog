class Account::CalendarController < Account::ApplicationController

  before_action { add_breadcrumb t("account.calendar.breadcrumb"), account_calendar_index_path }

end
