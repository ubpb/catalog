class Account::LoansHistoryController < Account::ApplicationController

  before_action { add_breadcrumb t("account.loans_history.breadcrumb"), account_loans_history_index_path }

  def index
    if turbo_frame_request?
      sortable_fields    = Ils.adapter.former_loans_sortable_fields || []
      sortable_field     = sortable_fields.find{|f| f == params[:s]} || Ils.adapter.former_loans_sortable_default_field
      sortable_direction = ["asc", "desc"].find{|d| d == params[:d]} || Ils.adapter.former_loans_sortable_default_direction

      loans_result = Ils.get_former_loans(
        current_user.ils_primary_id,
        {
          per_page: 25,
          page: params[:page],
          disable_pagination: false,
          order_by: sortable_field,
          direction: sortable_direction
        }
      )

      render partial: "listing", locals: {
        loans_result: loans_result,
        sortable_fields: sortable_fields,
        sortable_field: sortable_field,
        sortable_direction: sortable_direction
      }
    else
      render :index
    end
  end

  def fixed
    @loans = FixedHistoryLoan
      .where(ils_primary_id: current_user.ils_primary_id)
      .where("return_date >= ?", Date.today - 180.days)
      .order("return_date desc")
  end

end
