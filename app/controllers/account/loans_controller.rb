class Account::LoansController < Account::ApplicationController

  def index
    if request.xhr?
      load_loans
      render :index_xhr, layout: false
    else
      render :index
    end
  end

  def renew
    ensure_xhr!

    result = renew_loan(params[:id])

    render partial: "loan", locals: {loan: result.loan, renew_result: result}
  end

private

  def load_loans
    result = Ils[:default].get_current_loans(
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
    Ils[:default].renew_loan(
      current_user.ils_primary_id,
      loan_id
    )
  end

end
