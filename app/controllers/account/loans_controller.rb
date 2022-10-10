class Account::LoansController < Account::ApplicationController

  before_action { add_breadcrumb t("account.loans.breadcrumb"), account_loans_path }

  def index
    if request.xhr?
      sortable_fields    = Ils.adapter.current_loans_sortable_fields || []
      sortable_field     = sortable_fields.find{|f| f == params[:s]} || Ils.adapter.current_loans_sortable_default_field
      sortable_direction = ["asc", "desc"].find{|d| d == params[:d]} || Ils.adapter.current_loans_sortable_default_direction

      result = load_loans(order_by: sortable_field, direction: sortable_direction)

      render partial: "loans", locals: {
        loans_result: result,
        sortable_fields: sortable_fields,
        sortable_field: sortable_field,
        sortable_direction: sortable_direction
      }
    else
      render :index
    end
  end

  def renew
    ensure_xhr!

    result = renew_loan(params[:id])

    render partial: "loan", locals: {
      loan: result.loan,
      renew_result: result,
      allow_single_renew: true
    }
  end

  def renew_all
    ensure_xhr!

    renewals = renew_loans

    render partial: "renewals", locals: {
      renewals: renewals
    }
  end

private

  def load_loans(order_by: nil, direction: nil)
    Ils.get_current_loans(
      current_user.ils_primary_id,
      {
        per_page: 25,
        page: params[:page],
        disable_pagination: false,
        order_by: order_by,
        direction: direction
      }
    )
  end

  def renew_loan(loan_id)
    Ils.renew_loan(
      current_user.ils_primary_id,
      loan_id
    )
  end

  def renew_loans
    Ils.renew_loans(
      current_user.ils_primary_id
    )
  end

end
