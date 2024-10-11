class Account::IdCardsController < Account::ApplicationController

  before_action { add_breadcrumb t("account.id_cards.breadcrumb"), account_id_card_path }
  before_action :ensure_turbo_frame_request, except: [:download_printout]
  before_action :load_ils_user

  def show
    authorize!
  end

  def authorize
    @set_pin_form = PinForm.new

    if request.post?
      pin = params[:pin]&.to_s&.strip.presence

      if pin && @ils_user.has_pin_set? && (pin == @ils_user.pin)
        session[:id_card_authorized] = true
        session[:id_card_authorized_at] = Time.zone.now
        redirect_to account_id_card_path
      else
        reset_authorization!
        flash[:error] = t(".error_notice")
        redirect_to authorize_account_id_card_path
      end
    end
  end

  def set_pin
    @set_pin_form = PinForm.new(
      params.require(:pin_form).permit(:pin, :pin_confirmation)
    )

    if @set_pin_form.valid? && Ils.set_user_pin(current_user.ils_primary_id, @set_pin_form.pin)
      session[:id_card_authorized] = true
      session[:id_card_authorized_at] = Time.zone.now
      redirect_to account_id_card_path
    else
      render "authorize", status: :unprocessable_entity
    end
  end

  def download_printout
    pdf = IdCardPdfGeneratorService.generate(@ils_user)

    send_data(
      pdf,
      filename: "#{@ils_user.short_barcode}.pdf",
      type: "application/pdf",
      disposition: "attachment"
    )

    true
  end

  private

  def ensure_turbo_frame_request
    redirect_to account_root_path unless turbo_frame_request?
  end

  def load_ils_user
    @ils_user = current_user.ils_user(force_reload: true)
  end

  def reset_authorization!
    session[:id_card_authorized] = nil
    session[:id_card_authorized_at] = nil
  end

  def authorized?
    session[:id_card_authorized] == true && session[:id_card_authorized_at] >= 5.minutes.ago
  end

  def authorize!
    unless @ils_user.has_pin_set?
      reset_authorization!
      redirect_to authorize_account_id_card_path
      return false
    end

    unless authorized?
      reset_authorization!
      redirect_to authorize_account_id_card_path
      return false
    end

    true
  end

end
