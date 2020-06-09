class Account::FeesController < Account::ApplicationController

  def index
    if request.xhr?
      fees = load_fees
      sum = fees.sum{|f| f.balance}
      render partial: "fees", locals: {
        sum: sum,
        fees: fees
      }
    else
      render :index
    end
  end

private

  def load_fees
    Ils[:default].get_fees(
      current_user.ils_primary_id
    )
  end

end
