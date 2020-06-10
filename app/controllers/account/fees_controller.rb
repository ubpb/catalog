class Account::FeesController < Account::ApplicationController

  def index
    if request.xhr?
      # Load fees
      fees = load_fees
      # Sort by date desc
      fees = fees.sort{|x,y| y.date <=> x.date}
      # Calc the fees sum
      sum = fees.sum{|f| f.balance}

      # Render fees listing
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
