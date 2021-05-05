class Account::LoansController < Account::ApplicationController

  before_action { add_breadcrumb t("account.loans.breadcrumb"), account_loans_path }

  def index
    if request.xhr?
      load_loans

      render partial: "loans", locals: {
        loans: @loans,
        total_number_of_loans: @total_number_of_loans
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

  def load_loans
    result = Ils.get_current_loans(
      current_user.ils_primary_id,
      {
        per_page: params[:per_page],
        page: params[:page]
      }
    )

    @total_number_of_loans = result.total_number_of_loans

    @loans = Kaminari.paginate_array(
      result.loans,
      total_count: @total_number_of_loans
    ).page(result.page).per(result.per_page)
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
