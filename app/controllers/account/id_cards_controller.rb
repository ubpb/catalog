class Account::IdCardsController < Account::ApplicationController

  before_action { add_breadcrumb t("account.id_cards.breadcrumb"), account_id_card_path }
  before_action :ensure_turbo_frame_request, except: [:download_printout]
  before_action :load_ils_user

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

end
