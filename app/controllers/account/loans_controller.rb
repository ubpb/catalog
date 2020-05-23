class Account::LoansController < Account::ApplicationController

  PER_PAGE_DEFAULT = 2
  PER_PAGE_MAX     = 100
  PAGE_DEFAULT     = 1

  def index
    per_page = per_page_value(params[:per_page])
    page     = page_value(params[:page])

    result = Ils[:default].get_current_loans(
      current_user.ils_primary_id,
      {
        per_page: per_page,
        page: page
      }
    )

    @loans = Kaminari.paginate_array(
      result.loans,
      total_count: result.total_number_of_loans
    ).page(page).per(per_page)
  end

private

  def per_page_value(value)
    value = value.to_i
    value = (value <= 0) ? PER_PAGE_DEFAULT : value
    (value >= 100) ? PER_PAGE_MAX : value
  end

  def page_value(value)
    value = value.to_i
    (value <= 0) ? PAGE_DEFAULT : value
  end

end
